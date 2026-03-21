from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import HybridSwitchRequest
from .serializers import (
	HybridSwitchRequestSerializer,
	HybridSwitchSubmitSerializer,
	HybridSwitchUploadSerializer,
)


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
