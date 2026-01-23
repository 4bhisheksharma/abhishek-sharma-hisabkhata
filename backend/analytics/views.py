from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum, Count
from transaction.models import Transaction
from customer_dashboard.models import CustomerBusinessRelationship, Customer
from business_dashboard.models import Business
from django.db.models.functions import TruncMonth
from django.utils import timezone
from dateutil.relativedelta import relativedelta

# Create your views here.

class PaidVsToPayView(APIView):
    """API view for paid vs to pay analytics data"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """
        Returns data for paid vs to pay bar graph.
        For businesses: 
            - Paid: total amount received from all customers
            - To Pay: total amount all customers owe to the business
        For customers:
            - Paid: total amount paid to all businesses
            - To Pay: total amount owed to all businesses
        """
        user = request.user
        
        # Check if user is a business
        try:
            business = user.business_profile
            # Get all relationships for this business
            relationships = CustomerBusinessRelationship.objects.filter(business=business)
            
            # Calculate total to pay (positive amounts - customers owe business)
            total_to_pay = Transaction.objects.filter(
                relationship__in=relationships, 
                amount__gt=0
            ).aggregate(total=Sum('amount'))['total'] or 0
            
            # Calculate total paid (absolute value of negative amounts - payments received)
            total_paid_negative = Transaction.objects.filter(
                relationship__in=relationships, 
                amount__lt=0
            ).aggregate(total=Sum('amount'))['total'] or 0
            
            total_paid = abs(total_paid_negative)
            
        except AttributeError:
            # User is not a business, check if customer
            try:
                customer = user.customer_profile
                # Get all relationships for this customer
                relationships = CustomerBusinessRelationship.objects.filter(customer=customer)
                
                # Calculate total to pay (positive amounts - customer owes businesses)
                total_to_pay = Transaction.objects.filter(
                    relationship__in=relationships, 
                    amount__gt=0
                ).aggregate(total=Sum('amount'))['total'] or 0
                
                # Calculate total paid (absolute value of negative amounts - payments made)
                total_paid_negative = Transaction.objects.filter(
                    relationship__in=relationships, 
                    amount__lt=0
                ).aggregate(total=Sum('amount'))['total'] or 0
                
                total_paid = abs(total_paid_negative)
                
            except AttributeError:
                return Response({'error': 'User must be either a business or customer'}, status=status.HTTP_403_FORBIDDEN)
        
        data = {
            'paid': float(total_paid),
            'to_pay': float(total_to_pay)
        }
        
        return Response(data)


class MonthlyTransactionTrendView(APIView):
    """API view for user's monthly transaction trend data"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """
        Returns monthly transaction trend data for the authenticated user.
        Shows transaction amounts by month for the past 12 months.
        Suitable for line chart visualization.
        """
        try:
            # Get customer profile
            customer = request.user.customer_profile
            
            # Get all relationships for this customer
            relationships = CustomerBusinessRelationship.objects.filter(customer=customer)
            
            # Calculate date range (last 12 months)
            end_date = timezone.now()
            start_date = end_date - relativedelta(months=11)
            start_date = start_date.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            
            # Get monthly transaction data
            monthly_data = Transaction.objects.filter(
                relationship__in=relationships,
                transaction_date__gte=start_date,
                transaction_date__lte=end_date
            ).annotate(
                month=TruncMonth('transaction_date')
            ).values('month').annotate(
                total_amount=Sum('amount'),
                transaction_count=Count('transaction_id')
            ).order_by('month')
            
            # Format data for chart
            trend_data = []
            current_date = start_date
            
            # Create a map of existing data
            data_map = {}
            for item in monthly_data:
                month_key = item['month'].strftime('%Y-%m')
                data_map[month_key] = {
                    'total_amount': float(item['total_amount']),
                    'transaction_count': item['transaction_count']
                }
            
            # Fill in all months (including those with no transactions)
            for i in range(12):
                month_key = current_date.strftime('%Y-%m')
                month_name = current_date.strftime('%b %Y')
                
                if month_key in data_map:
                    trend_data.append({
                        'month': month_name,
                        'total_amount': data_map[month_key]['total_amount'],
                        'transaction_count': data_map[month_key]['transaction_count']
                    })
                else:
                    trend_data.append({
                        'month': month_name,
                        'total_amount': 0.00,
                        'transaction_count': 0
                    })
                
                current_date += relativedelta(months=1)
            
            return Response({
                'status': 200,
                'message': 'Monthly transaction trend retrieved successfully',
                'data': trend_data
            }, status=status.HTTP_200_OK)
            
        except AttributeError:
            return Response({
                'status': 403,
                'message': 'Only customer users can access transaction trends',
                'data': None
            }, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving transaction trend: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class TotalTransactionsView(APIView):
    """API view for total transaction count analytics"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Returns the total count of all transactions for the authenticated user.
        For businesses: count of all transactions with their customers
        For customers: count of all transactions with their businesses
        """
        user = request.user

        # Check if user is a business
        try:
            business = user.business_profile
            # Get all relationships for this business
            relationships = CustomerBusinessRelationship.objects.filter(business=business)

            # Count all transactions for this business
            total_transactions = Transaction.objects.filter(
                relationship__in=relationships
            ).count()

            user_type = 'business'
            message = f'You have {total_transactions} transactions total'

        except AttributeError:
            # User is not a business, check if customer
            try:
                customer = user.customer_profile
                # Get all relationships for this customer
                relationships = CustomerBusinessRelationship.objects.filter(customer=customer)

                # Count all transactions for this customer
                total_transactions = Transaction.objects.filter(
                    relationship__in=relationships
                ).count()

                user_type = 'customer'
                message = f'You have {total_transactions} transactions total'

            except AttributeError:
                return Response({
                    'status': 403,
                    'message': 'User must be either a business or customer',
                    'data': None
                }, status=status.HTTP_403_FORBIDDEN)

        return Response({
            'status': 200,
            'message': message,
            'data': {
                'total_transactions': total_transactions,
                'user_type': user_type
            }
        }, status=status.HTTP_200_OK)


class TotalAmountView(APIView):
    """API view for total transaction amount analytics"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Returns the total sum of transaction amounts for the authenticated user.
        For businesses: Total revenue (sum of amounts received)
        For customers: Total spent (absolute value of amounts paid)
        """
        user = request.user

        # Check if user is a business
        try:
            business = user.business_profile
            # Get all relationships for this business
            relationships = CustomerBusinessRelationship.objects.filter(business=business)

            # Calculate total revenue (sum of all positive amounts received)
            total_revenue = Transaction.objects.filter(
                relationship__in=relationships,
                amount__gt=0
            ).aggregate(total=Sum('amount'))['total'] or 0

            user_type = 'business'
            message = f'Total revenue: Rs. {total_revenue:.2f}'
            total_amount = float(total_revenue)

        except AttributeError:
            # User is not a business, check if customer
            try:
                customer = user.customer_profile
                # Get all relationships for this customer
                relationships = CustomerBusinessRelationship.objects.filter(customer=customer)

                # Calculate total spent (absolute value of negative amounts paid)
                total_spent_negative = Transaction.objects.filter(
                    relationship__in=relationships,
                    amount__lt=0
                ).aggregate(total=Sum('amount'))['total'] or 0

                total_spent = abs(total_spent_negative)

                user_type = 'customer'
                message = f'Total spent: Rs. {total_spent:.2f}'
                total_amount = float(total_spent)

            except AttributeError:
                return Response({
                    'status': 403,
                    'message': 'User must be either a business or customer',
                    'data': None
                }, status=status.HTTP_403_FORBIDDEN)

        return Response({
            'status': 200,
            'message': message,
            'data': {
                'total_amount': total_amount,
                'user_type': user_type
            }
        }, status=status.HTTP_200_OK)


class MonthlySpendingLimitView(APIView):
    """API view for customer's monthly spending vs limit analytics"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Returns customer's monthly spending data compared to their set limit.
        Shows total spent this month, monthly limit, remaining budget, and budget status.
        Only accessible by customer users.
        """
        try:
            # Get customer profile
            customer = request.user.customer_profile

            # Use the manager method to get spending overview
            spending_data = Customer.objects.get_monthly_spending_overview(customer)

            return Response({
                'status': 200,
                'message': 'Monthly spending limit data retrieved successfully',
                'data': spending_data
            }, status=status.HTTP_200_OK)

        except AttributeError:
            return Response({
                'status': 403,
                'message': 'Only customer users can access monthly spending limit data',
                'data': None
            }, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({
                'status': 500,
                'message': f'Error retrieving monthly spending data: {str(e)}',
                'data': None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
