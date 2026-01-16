from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum, Q, Count
from .models import Business
from .serializers import BusinessDashboardSerializer, BusinessProfileSerializer, RecentCustomerSerializer
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
