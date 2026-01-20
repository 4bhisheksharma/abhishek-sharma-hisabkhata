from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum, Q, Count
from .models import Customer, CustomerBusinessRelationship
from .serializers import CustomerDashboardSerializer, CustomerProfileSerializer, RecentBusinessSerializer
from request.models import BusinessCustomerRequest


class CustomerDashboardView(APIView):
    """Customer home dashboard overview"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get customer profile
            customer = Customer.objects.get(user=request.user)
            
            # Get all relationships for this customer
            relationships = CustomerBusinessRelationship.objects.filter(customer=customer)
            
            # Calculate to_give: sum of all positive pending_due (customer owes businesses)
            to_give_total = relationships.filter(
                pending_due__gt=0
            ).aggregate(total=Sum('pending_due'))['total'] or 0
            
            # Calculate to_take: sum of all negative pending_due (businesses owe customer)
            # Convert to positive for display
            to_take_total = relationships.filter(
                pending_due__lt=0
            ).aggregate(total=Sum('pending_due'))['total'] or 0
            to_take_total = abs(to_take_total)
            
            # Count total connected businesses
            total_shops = relationships.count()
            
            # Count pending connection requests (both sent and received)
            pending_requests = BusinessCustomerRequest.objects.filter(
                Q(sender=request.user, status='pending') | 
                Q(receiver=request.user, status='pending')
            ).count()
            
            # Calculate loyalty points (max 10)
            # Connection Points (Max 5): +1 point per connected business
            connection_points = min(5, total_shops)
            
            # Transaction Points (Max 5): +1 point per Rs. 500 paid
            from transaction.models import Transaction
            total_paid = Transaction.objects.filter(
                relationship__customer=customer,
                transaction_type='payment'
            ).aggregate(total=Sum('amount'))['total'] or 0
            # Convert to positive since payments are stored as negative
            total_paid = abs(total_paid)
            transaction_points = min(5, int(total_paid / 500))
            
            # Total loyalty points (max 10)
            loyalty_points = min(10, connection_points + transaction_points)
            
            # Add computed fields to customer instance
            customer.to_give = to_give_total
            customer.to_take = to_take_total
            customer.total_shops = total_shops
            customer.pending_requests = pending_requests
            customer.loyalty_points = loyalty_points
            
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


class RecentBusinessesView(APIView):
    """Get recently added businesses for a customer"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            # Get customer profile
            customer = Customer.objects.get(user=request.user)
            
            # Get limit from query params (default 10)
            limit = int(request.query_params.get('limit', 10))
            
            # Get recent business relationships ordered by created_at descending
            recent_relationships = CustomerBusinessRelationship.objects.filter(
                customer=customer
            ).select_related(
                'business', 
                'business__user'
            ).order_by('-created_at')[:limit]
            
            # Serialize the data
            serializer = RecentBusinessSerializer(recent_relationships, many=True)
            
            return Response({
                'status': 200,
                'message': 'Recent businesses retrieved successfully',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
            
        except Customer.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Customer profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving recent businesses: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class MonthlySpendingOverviewView(APIView):
    """View for customers to get overall monthly spending overview across all businesses"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get overall monthly spending summary for the customer"""
        try:
            # Check if user is a customer
            customer = request.user.customer_profile
            
            # Get spending overview
            overview = Customer.objects.get_monthly_spending_overview(customer)
            
            return Response({
                'status': 200,
                'message': 'Monthly spending overview retrieved successfully',
                'data': overview
            }, status=status.HTTP_200_OK)
            
        except AttributeError:
            return Response({
                'status': 403,
                'message': 'Only customer users can access spending overview',
                'data': None
            }, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving spending overview: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class MonthlyLimitView(APIView):
    """View for customers to set and get their monthly spending limit"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get customer's current monthly limit"""
        try:
            customer = request.user.customer_profile
            
            return Response({
                'status': 200,
                'message': 'Monthly limit retrieved successfully',
                'data': {
                    'monthly_limit': float(customer.monthly_limit) if customer.monthly_limit > 0 else None
                }
            }, status=status.HTTP_200_OK)
            
        except AttributeError:
            return Response({
                'status': 403,
                'message': 'Only customer users can access monthly limits',
                'data': None
            }, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving monthly limit: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def post(self, request):
        """Set customer's monthly spending limit"""
        try:
            customer = request.user.customer_profile
            
            # Validate the monthly limit
            monthly_limit = request.data.get('monthly_limit')
            if monthly_limit is None:
                return Response({
                    'status': 400,
                    'message': 'monthly_limit field is required',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            try:
                monthly_limit = float(monthly_limit)
                if monthly_limit < 0:
                    return Response({
                        'status': 400,
                        'message': 'Monthly limit cannot be negative',
                        'data': None
                    }, status=status.HTTP_400_BAD_REQUEST)
            except (ValueError, TypeError):
                return Response({
                    'status': 400,
                    'message': 'Invalid monthly_limit value',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Update the monthly limit
            customer.monthly_limit = monthly_limit
            customer.save(update_fields=['monthly_limit', 'updated_at'])
            
            return Response({
                'status': 200,
                'message': 'Monthly spending limit set successfully',
                'data': {
                    'monthly_limit': float(customer.monthly_limit)
                }
            }, status=status.HTTP_200_OK)
            
        except AttributeError:
            return Response({
                'status': 403,
                'message': 'Only customer users can set monthly limits',
                'data': None
            }, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error setting monthly limit: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

