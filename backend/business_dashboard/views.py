from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum
from .models import Business
from .serializers import BusinessDashboardSerializer, BusinessProfileSerializer, RecentCustomerSerializer
from customer_dashboard.models import CustomerBusinessRelationship


class BusinessDashboardView(APIView):
    """Business home dashboard overview"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get business profile
            business = Business.objects.get(user=request.user)
            
            # Add computed fields to business instance
            business.to_give = 0  # TODO: Calculate from transactions
            business.to_take = 0  # TODO: Calculate from transactions
            business.total_customers = 0  # TODO: Count connected customers
            business.total_requests = 0  # TODO: Count pending requests
            
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
