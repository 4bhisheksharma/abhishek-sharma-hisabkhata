from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum
from .models import Customer
from .serializers import CustomerDashboardSerializer, CustomerProfileSerializer


class CustomerDashboardView(APIView):
    """Customer home dashboard overview"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get customer profile
            customer = Customer.objects.get(user=request.user)
            
            # Add computed fields to customer instance
            customer.to_give = 0  # TODO: Calculate from transactions
            customer.to_take = 0  # TODO: Calculate from transactions
            customer.total_shops = 0  # TODO: Count connected shops
            customer.pending_requests = 0  # TODO: Count pending requests
            customer.recent_transactions = []  # TODO: Get recent transactions
            customer.loyalty_points = 0  # TODO: Get loyalty points
            
            # Serialize with flattened structure
            serializer = CustomerDashboardSerializer(customer)
            
            return Response({
                'status': 200,
                'message': 'Dashboard data retrieved successfully',
                'data': serializer.data
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
            serializer = CustomerProfileSerializer(customer)
            
            return Response({
                'status': 200,
                'message': 'Profile retrieved successfully',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
            
        except Customer.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Customer profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
    
    def patch(self, request):
        """Update customer profile (partial update)"""
        try:
            customer = Customer.objects.get(user=request.user)
            serializer = CustomerProfileSerializer(customer, data=request.data, partial=True)
            
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'status': 200,
                    'message': 'Profile updated successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)
            
            return Response({
                'status': 400,
                'message': 'Invalid data',
                'data': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
            
        except Customer.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Customer profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)

