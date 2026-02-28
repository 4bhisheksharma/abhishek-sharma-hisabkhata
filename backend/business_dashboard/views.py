from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from django.db.models import Sum, Q, Count
from .models import Business, BusinessVerificationRequest
from .serializers import (
    BusinessDashboardSerializer, BusinessProfileSerializer,
    RecentCustomerSerializer, BusinessVerificationRequestSerializer,
    BusinessVerificationStatusSerializer
)
from customer_dashboard.models import CustomerBusinessRelationship
from request.models import BusinessCustomerRequest


class BusinessDashboardView(APIView):
    """Business home dashboard overview"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get business profile
            business = Business.objects.get(user=request.user)
            
            # Get all relationships for this business
            relationships = CustomerBusinessRelationship.objects.filter(business=business)
            
            # Calculate to_take: sum of all positive pending_due (customers owe business)
            to_take_total = relationships.filter(
                pending_due__gt=0
            ).aggregate(total=Sum('pending_due'))['total'] or 0
            
            # Calculate to_give: sum of all negative pending_due (business owes customers)
            # Convert to positive for display
            to_give_total = relationships.filter(
                pending_due__lt=0
            ).aggregate(total=Sum('pending_due'))['total'] or 0
            to_give_total = abs(to_give_total)
            
            # Count total connected customers
            total_customers = relationships.count()
            
            # Count pending connection requests (both sent and received)
            total_requests = BusinessCustomerRequest.objects.filter(
                Q(sender=request.user, status='pending') | 
                Q(receiver=request.user, status='pending')
            ).count()
            
            # Add computed fields to business instance
            business.to_give = to_give_total
            business.to_take = to_take_total
            business.total_customers = total_customers
            business.total_requests = total_requests
            
            # Serialize with flattened structure
            serializer = BusinessDashboardSerializer(business)
            
            return Response({
                'status': 200,
                'message': 'Dashboard data retrieved successfully',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
            
        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving dashboard data: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class BusinessProfileView(APIView):
    """Get and update business profile"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            business = Business.objects.get(user=request.user)
            serializer = BusinessProfileSerializer(business)
            
            return Response({
                'status': 200,
                'message': 'Profile retrieved successfully',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
            
        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving profile: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def patch(self, request):
        """Partial update of business profile"""
        try:
            business = Business.objects.get(user=request.user)
            serializer = BusinessProfileSerializer(business, data=request.data, partial=True)
            
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'status': 200,
                    'message': 'Profile updated successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)
            
            return Response({
                'status': 400,
                'message': 'Validation error',
                'data': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
            
        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error updating profile: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class RecentCustomersView(APIView):
    """Get recently added customers for a business"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get business profile
            business = Business.objects.get(user=request.user)
            
            # Get limit from query params (default 10)
            limit = int(request.query_params.get('limit', 10))
            
            # Get recent customer relationships ordered by created_at descending
            recent_relationships = CustomerBusinessRelationship.objects.filter(
                business=business
            ).select_related(
                'customer', 
                'customer__user'
            ).order_by('-created_at')[:limit]
            
            # Serialize the data
            serializer = RecentCustomerSerializer(recent_relationships, many=True)
            
            return Response({
                'status': 200,
                'message': 'Recent customers retrieved successfully',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
            
        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving recent customers: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class BusinessVerificationRequestView(APIView):
    """Submit a verification request with business shop document"""
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        """Submit a new verification request"""
        try:
            business = Business.objects.get(user=request.user)

            # Check if already verified
            if business.is_verified:
                return Response({
                    'status': 400,
                    'message': 'Business is already verified',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)

            # Check if there's already a pending request
            pending = BusinessVerificationRequest.objects.filter(
                business=business, status='pending'
            ).exists()
            if pending:
                return Response({
                    'status': 400,
                    'message': 'You already have a pending verification request',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)

            # Validate document is provided
            if 'document' not in request.FILES:
                return Response({
                    'status': 400,
                    'message': 'Document file is required',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)

            serializer = BusinessVerificationRequestSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save(business=business)
                return Response({
                    'status': 201,
                    'message': 'Verification request submitted successfully',
                    'data': serializer.data
                }, status=status.HTTP_201_CREATED)

            return Response({
                'status': 400,
                'message': 'Validation error',
                'data': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error submitting verification request: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def get(self, request):
        """Get all verification requests for the current business"""
        try:
            business = Business.objects.get(user=request.user)
            requests_qs = BusinessVerificationRequest.objects.filter(
                business=business
            ).order_by('-created_at')
            serializer = BusinessVerificationRequestSerializer(requests_qs, many=True)

            return Response({
                'status': 200,
                'message': 'Verification requests retrieved successfully',
                'data': serializer.data
            }, status=status.HTTP_200_OK)

        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving verification requests: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class BusinessVerificationStatusView(APIView):
    """Get current verification status for the business"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            business = Business.objects.get(user=request.user)
            latest_request = BusinessVerificationRequest.objects.filter(
                business=business
            ).order_by('-created_at').first()

            has_pending = BusinessVerificationRequest.objects.filter(
                business=business, status='pending'
            ).exists()

            data = {
                'is_verified': business.is_verified,
                'has_pending_request': has_pending,
                'latest_request': BusinessVerificationRequestSerializer(latest_request).data if latest_request else None
            }

            return Response({
                'status': 200,
                'message': 'Verification status retrieved successfully',
                'data': data
            }, status=status.HTTP_200_OK)

        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving verification status: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
