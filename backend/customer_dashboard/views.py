from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum
from .models import Customer
from .serializers import CustomerSerializer


class CustomerDashboardView(APIView):
    """Customer home dashboard overview"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get customer profile
            customer = Customer.objects.get(user=request.user)
            
            # TODO: Calculate total dues from transactions (when transaction app is created)
            total_dues = 0
            
            # TODO: Count connected shops (when relationship app is created)
            total_shops = 0
            
            # TODO: Count pending requests (when relationship app is created)
            pending_requests = 0
            
            # TODO: Get recent transactions (when transaction app is created)
            recent_transactions = []
            
            # Prepare dashboard data
            dashboard_data = {
                'customer': CustomerSerializer(customer).data,
                'total_dues': total_dues,
                'total_shops': total_shops,
                'pending_requests': pending_requests,
                'recent_transactions': recent_transactions,
            }
            
            return Response({
                'status': 200,
                'message': 'Dashboard data retrieved successfully',
                'data': dashboard_data
            }, status=status.HTTP_200_OK)
            
        except Customer.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'lungs is injurious to health!!, customer profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving dashboard data: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CustomerProfileView(APIView):
    """Get and update customer profile"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            customer = Customer.objects.get(user=request.user)
            serializer = CustomerSerializer(customer)
            
            return Response({
                'status': 200,
                'message': 'aayo bhai aayo!!',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
            
        except Customer.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'lungs is injurious to health!!, customer profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
