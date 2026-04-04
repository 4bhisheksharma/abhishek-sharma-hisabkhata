from django.utils import timezone
from django.db import transaction
from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import render, redirect

from .models import HybridSwitchRequest
from .serializers import (
	HybridSwitchRequestSerializer,
	HybridSwitchSubmitSerializer,
	HybridSwitchUploadSerializer,
)
from business_dashboard.models import Business
from customer_dashboard.models import Customer
from notification.models import Notification


def _activate_hybrid_mode_for_user(user):
	"""Ensure approved hybrid users have both business and customer profiles."""
	from hisabauth.models import Role, UserRole

	if not hasattr(user, 'customer_profile'):
		Customer.objects.create(user=user)
	
	# Ensure customer role exists
	cust_role, _ = Role.objects.get_or_create(name='customer')
	UserRole.objects.get_or_create(user=user, role=cust_role)

	if not hasattr(user, 'business_profile'):
		base_name = (user.full_name or '').strip() or user.email or f'User {user.user_id}'
		Business.objects.create(
			user=user,
			business_name=f"{base_name}'s Business",
			is_verified=False,
		)
	
	# Ensure business role exists
	biz_role, _ = Role.objects.get_or_create(name='business')
	UserRole.objects.get_or_create(user=user, role=biz_role)
class HybridAccountStatusView(APIView):
	permission_classes = [IsAuthenticated]

	def get(self, request):
		user = request.user
		has_business = hasattr(user, 'business_profile')
		has_customer = hasattr(user, 'customer_profile')

		if has_business and has_customer:
			return Response(
				{
					'account_type': 'hybrid',
					'is_business_verified': bool(user.business_profile.is_verified),
					'can_request': False,
					'message': 'User already has both business and customer profiles.',
				},
				status=status.HTTP_200_OK,
			)

		if has_business:
			account_type = 'business'
			is_business_verified = bool(user.business_profile.is_verified)
		elif has_customer:
			account_type = 'customer'
			is_business_verified = False
		else:
			return Response(
				{'detail': 'No business or customer profile found for this user.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		has_pending = HybridSwitchRequest.objects.filter(
			user=user,
			status='pending',
		).exists()

		can_request = (
			is_business_verified if account_type == 'business' else True
		) and not has_pending

		latest_request = HybridSwitchRequest.objects.filter(user=user).first()

		return Response(
			{
				'account_type': account_type,
				'is_business_verified': is_business_verified,
				'can_request': can_request,
				'has_pending_request': has_pending,
				'latest_request': HybridSwitchRequestSerializer(
					latest_request,
					context={'request': request},
				).data
				if latest_request
				else None,
			},
			status=status.HTTP_200_OK,
		)


class HybridCitizenshipUploadView(APIView):
	permission_classes = [IsAuthenticated]

	def post(self, request):
		upload_serializer = HybridSwitchUploadSerializer(data=request.data)
		upload_serializer.is_valid(raise_exception=True)

		user = request.user
		has_business = hasattr(user, 'business_profile')
		has_customer = hasattr(user, 'customer_profile')

		if has_business and has_customer:
			return Response(
				{'detail': 'User is already hybrid. No request required.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		if has_business:
			account_type = 'business'
			is_business_verified = bool(user.business_profile.is_verified)
		elif has_customer:
			account_type = 'customer'
			is_business_verified = False
		else:
			return Response(
				{'detail': 'No business or customer profile found for this user.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		pending_request = HybridSwitchRequest.objects.filter(
			user=user,
			status='pending',
		).first()
		if pending_request:
			return Response(
				{
					'detail': 'A hybrid switch request is already pending review.',
					'request': HybridSwitchRequestSerializer(
						pending_request,
						context={'request': request},
					).data,
				},
				status=status.HTTP_400_BAD_REQUEST,
			)

		draft_request = HybridSwitchRequest.objects.filter(
			user=user,
			status='draft',
		).first()

		citizenship_document = upload_serializer.validated_data['citizenship_document']

		if draft_request:
			draft_request.citizenship_document = citizenship_document
			draft_request.account_type = account_type
			draft_request.is_business_verified_at_request = is_business_verified
			draft_request.save()
			hybrid_request = draft_request
		else:
			hybrid_request = HybridSwitchRequest.objects.create(
				user=user,
				account_type=account_type,
				is_business_verified_at_request=is_business_verified,
				citizenship_document=citizenship_document,
				status='draft',
			)

		return Response(
			{
				'message': 'Citizenship uploaded successfully.',
				'request': HybridSwitchRequestSerializer(
					hybrid_request,
					context={'request': request},
				).data,
			},
			status=status.HTTP_201_CREATED,
		)


class HybridSwitchSubmitView(APIView):
	permission_classes = [IsAuthenticated]

	def post(self, request):
		submit_serializer = HybridSwitchSubmitSerializer(data=request.data)
		submit_serializer.is_valid(raise_exception=True)

		user = request.user
		has_business = hasattr(user, 'business_profile')
		has_customer = hasattr(user, 'customer_profile')

		if has_business and has_customer:
			return Response(
				{'detail': 'User is already hybrid. No request required.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		if has_business and not user.business_profile.is_verified:
			return Response(
				{
					'detail': 'Business account must be verified before submitting hybrid request.'
				},
				status=status.HTTP_403_FORBIDDEN,
			)

		existing_pending = HybridSwitchRequest.objects.filter(
			user=user,
			status='pending',
		).first()
		if existing_pending:
			return Response(
				{
					'detail': 'A hybrid switch request is already pending review.',
					'request': HybridSwitchRequestSerializer(
						existing_pending,
						context={'request': request},
					).data,
				},
				status=status.HTTP_400_BAD_REQUEST,
			)

		hybrid_request_id = submit_serializer.validated_data.get('hybrid_request_id')

		draft_query = HybridSwitchRequest.objects.filter(
			user=user,
			status='draft',
		)
		if hybrid_request_id:
			draft_query = draft_query.filter(hybrid_request_id=hybrid_request_id)

		draft_request = draft_query.first()

		if not draft_request:
			return Response(
				{'detail': 'No draft hybrid request found. Upload citizenship first.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		if not draft_request.citizenship_document:
			return Response(
				{'detail': 'Citizenship document is required.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		draft_request.status = 'pending'
		draft_request.submitted_at = timezone.now()
		draft_request.save(update_fields=['status', 'submitted_at', 'updated_at'])

		return Response(
			{
				'message': 'Hybrid switch request submitted successfully.',
				'request': HybridSwitchRequestSerializer(
					draft_request,
					context={'request': request},
				).data,
			},
			status=status.HTTP_200_OK,
		)


class MyHybridSwitchRequestsView(APIView):
	permission_classes = [IsAuthenticated]

	def get(self, request):
		queryset = HybridSwitchRequest.objects.filter(user=request.user)
		serializer = HybridSwitchRequestSerializer(
			queryset,
			many=True,
			context={'request': request},
		)
		return Response(serializer.data, status=status.HTTP_200_OK)


@staff_member_required
def admin_hybrid_switch_requests_view(request):
	"""Admin dashboard section for reviewing hybrid switch requests."""

	if request.method == 'POST':
		request_id = request.POST.get('request_id')
		decision = request.POST.get('decision')
		admin_remarks = (request.POST.get('admin_remarks') or '').strip()

		if not request_id or decision not in ['approved', 'rejected', 'unapprove']:
			messages.error(request, 'Invalid review request payload.')
			return redirect('admin_hybrid_switch_requests')

		with transaction.atomic():
			hybrid_request = (
				HybridSwitchRequest.objects.select_for_update()
				.filter(hybrid_request_id=request_id)
				.first()
			)
			if not hybrid_request:
				messages.error(request, 'Hybrid switch request not found.')
				return redirect('admin_hybrid_switch_requests')

			if decision in ['approved', 'rejected'] and hybrid_request.status != 'pending':
				messages.warning(
					request,
					f'Request #{hybrid_request.hybrid_request_id} is already {hybrid_request.status}.',
				)
				return redirect('admin_hybrid_switch_requests')

			if decision == 'unapprove' and hybrid_request.status != 'approved':
				messages.warning(
					request,
					f'Only approved requests can be unapproved. Current status: {hybrid_request.status}.',
				)
				return redirect('admin_hybrid_switch_requests')

			if decision == 'unapprove':
				hybrid_request.status = 'pending'
				if admin_remarks:
					hybrid_request.admin_remarks = admin_remarks
				hybrid_request.reviewed_by = None
				hybrid_request.reviewed_at = None
			else:
				hybrid_request.status = decision
				hybrid_request.admin_remarks = admin_remarks or None
				hybrid_request.reviewed_by = request.user
				hybrid_request.reviewed_at = timezone.now()
				if decision == 'approved':
					_activate_hybrid_mode_for_user(hybrid_request.user)
			hybrid_request.save(
				update_fields=[
					'status',
					'admin_remarks',
					'reviewed_by',
					'reviewed_at',
					'updated_at',
				]
			)

		messages.success(
			request,
			f'Request #{hybrid_request.hybrid_request_id} {"moved back to pending" if decision == "unapprove" else decision} successfully.',
		)
		return redirect('admin_hybrid_switch_requests')

	status_filter = request.GET.get('status', 'pending')
	allowed_statuses = ['all', 'pending', 'approved', 'rejected']
	if status_filter not in allowed_statuses:
		status_filter = 'pending'

	requests_qs = HybridSwitchRequest.objects.select_related(
		'user',
		'reviewed_by',
	)
	if status_filter != 'all':
		requests_qs = requests_qs.filter(status=status_filter)

	context = {
		'hybrid_requests': requests_qs,
		'status_filter': status_filter,
		'pending_count': HybridSwitchRequest.objects.filter(status='pending').count(),
		'approved_count': HybridSwitchRequest.objects.filter(status='approved').count(),
		'rejected_count': HybridSwitchRequest.objects.filter(status='rejected').count(),
		'total_count': HybridSwitchRequest.objects.count(),
		'unread_notifications': Notification.objects.filter(
			receiver=request.user,
			is_read=False,
		).count(),
		'admin_user': request.user,
	}
	return render(request, 'admin_hybrid_switch_requests.html', context)
