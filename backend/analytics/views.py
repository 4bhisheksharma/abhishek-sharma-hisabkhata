from django.shortcuts import render
from django.contrib.admin.views.decorators import staff_member_required
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Sum, Count, Q
from django.db.models.functions import TruncMonth, TruncDate
from django.utils import timezone
from dateutil.relativedelta import relativedelta
import json

from transaction.models import Transaction
from customer_dashboard.models import CustomerBusinessRelationship, Customer
from business_dashboard.models import Business
from hisabauth.models import User, Role, UserRole
from support_ticket.models import SupportTicket
from request.models import BusinessCustomerRequest
from notification.models import Notification

# Create your views here.


@staff_member_required
def admin_dashboard_view(request):
    """Render the admin dashboard with real statistics."""
    now = timezone.now()
    last_month_start = (now - relativedelta(months=1)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    this_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # --- Stats cards ---
    total_businesses = Business.objects.count()
    total_businesses_last_month = Business.objects.filter(created_at__lt=this_month_start).count()
    businesses_last_month_count = Business.objects.filter(
        created_at__gte=last_month_start, created_at__lt=this_month_start
    ).count()
    business_growth = round(
        (businesses_last_month_count / max(total_businesses_last_month - businesses_last_month_count, 1)) * 100
    ) if total_businesses_last_month else 0

    active_customers = Customer.objects.filter(status='active').count()
    customers_last_month_count = Customer.objects.filter(
        created_at__gte=last_month_start, created_at__lt=this_month_start
    ).count()
    total_customers_before = Customer.objects.filter(created_at__lt=this_month_start).count()
    customer_growth = round(
        (customers_last_month_count / max(total_customers_before - customers_last_month_count, 1)) * 100
    ) if total_customers_before else 0

    total_transactions = Transaction.objects.count()
    transactions_last_month = Transaction.objects.filter(
        created_at__gte=last_month_start, created_at__lt=this_month_start
    ).count()
    transactions_before = Transaction.objects.filter(created_at__lt=this_month_start).count()
    transaction_growth = round(
        (transactions_last_month / max(transactions_before - transactions_last_month, 1)) * 100
    ) if transactions_before else 0

    urgent_tickets = SupportTicket.objects.filter(
        Q(priority='urgent') | Q(priority='high'),
        status__in=['open', 'in_progress']
    ).count()
    total_open_tickets = SupportTicket.objects.filter(status__in=['open', 'in_progress']).count()

    # --- User distribution ---
    total_users = User.objects.filter(is_active=True).count()
    num_customers = Customer.objects.count()
    num_businesses = Business.objects.count()
    num_staff = User.objects.filter(is_staff=True, is_superuser=False).count()
    num_admins = User.objects.filter(is_superuser=True).count()

    if total_users > 0:
        pct_customers = round((num_customers / total_users) * 100, 2)
        pct_businesses = round((num_businesses / total_users) * 100, 2)
        pct_staff = round((num_staff / total_users) * 100, 2)
        pct_admins = round((num_admins / total_users) * 100, 2)
    else:
        pct_customers = pct_businesses = pct_staff = pct_admins = 0

    # --- Platform growth (last 6 months) ---
    six_months_ago = (now - relativedelta(months=5)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    growth_labels = []
    business_growth_data = []
    customer_growth_data = []

    for i in range(6):
        month_date = six_months_ago + relativedelta(months=i)
        month_label = month_date.strftime('%b')
        growth_labels.append(month_label)

        biz_count = Business.objects.filter(created_at__lte=month_date + relativedelta(months=1)).count()
        cust_count = Customer.objects.filter(created_at__lte=month_date + relativedelta(months=1)).count()
        business_growth_data.append(biz_count)
        customer_growth_data.append(cust_count)

    # --- Recent activity ---
    recent_businesses = Business.objects.select_related('user').order_by('-created_at')[:5]
    recent_tickets = SupportTicket.objects.select_related('user').order_by('-created_at')[:5]
    recent_transactions = Transaction.objects.select_related(
        'relationship__customer__user', 'relationship__business'
    ).order_by('-created_at')[:5]

    # Build activity feed
    activities = []
    for biz in recent_businesses:
        activities.append({
            'type': 'business',
            'icon': 'fa-store',
            'color': '#00d09e',
            'text': f'New business registered: {biz.business_name}',
            'time': biz.created_at,
        })
    for ticket in recent_tickets:
        if ticket.status == 'resolved':
            activities.append({
                'type': 'ticket_resolved',
                'icon': 'fa-headset',
                'color': '#0288d1',
                'text': f'Support ticket resolved: {ticket.subject}',
                'time': ticket.updated_at,
            })
        else:
            activities.append({
                'type': 'ticket',
                'icon': 'fa-exclamation-triangle',
                'color': '#d32f2f',
                'text': f'Support ticket: {ticket.subject} ({ticket.get_priority_display()})',
                'time': ticket.created_at,
            })

    # Sort activities by time descending, take top 5
    activities.sort(key=lambda x: x['time'], reverse=True)
    activities = activities[:5]

    # Calculate time ago for each activity
    for activity in activities:
        delta = now - activity['time']
        if delta.days > 0:
            activity['time_ago'] = f"{delta.days} day{'s' if delta.days > 1 else ''} ago"
        elif delta.seconds >= 3600:
            hours = delta.seconds // 3600
            activity['time_ago'] = f"{hours} hour{'s' if hours > 1 else ''} ago"
        elif delta.seconds >= 60:
            minutes = delta.seconds // 60
            activity['time_ago'] = f"{minutes} minute{'s' if minutes > 1 else ''} ago"
        else:
            activity['time_ago'] = "Just now"

    context = {
        'total_businesses': total_businesses,
        'business_growth': business_growth,
        'active_customers': active_customers,
        'customer_growth': customer_growth,
        'total_transactions': total_transactions,
        'transaction_growth': transaction_growth,
        'urgent_tickets': urgent_tickets,
        'total_open_tickets': total_open_tickets,

        'pct_customers': pct_customers,
        'pct_businesses': pct_businesses,
        'pct_staff': pct_staff,
        'pct_admins': pct_admins,
        'num_customers': num_customers,
        'num_businesses': num_businesses,
        'num_staff': num_staff,
        'num_admins': num_admins,

        'growth_labels': json.dumps(growth_labels),
        'business_growth_data': json.dumps(business_growth_data),
        'customer_growth_data': json.dumps(customer_growth_data),

        'activities': activities,
        'admin_user': request.user,
    }
    return render(request, 'admin_dashboard.html', context)


class AdminDashboardStatsAPI(APIView):
    """API endpoint for admin dashboard statistics (JSON)."""
    permission_classes = [IsAdminUser]

    def get(self, request):
        now = timezone.now()
        data = {
            'total_businesses': Business.objects.count(),
            'active_customers': Customer.objects.filter(status='active').count(),
            'total_transactions': Transaction.objects.count(),
            'urgent_tickets': SupportTicket.objects.filter(
                Q(priority='urgent') | Q(priority='high'),
                status__in=['open', 'in_progress']
            ).count(),
            'total_users': User.objects.filter(is_active=True).count(),
        }
        return Response(data)


@staff_member_required
def admin_user_management_view(request):
    """Render the User Management page with real data."""
    now = timezone.now()
    last_month_start = (now - relativedelta(months=1)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    this_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # ── Stat cards ──
    total_business_owners = Business.objects.count()
    biz_before = Business.objects.filter(created_at__lt=this_month_start).count()
    biz_new = Business.objects.filter(created_at__gte=last_month_start, created_at__lt=this_month_start).count()
    biz_growth = round((biz_new / max(biz_before - biz_new, 1)) * 100) if biz_before else 0

    active_accounts = Business.objects.filter(is_verified=True).count()
    active_before = Business.objects.filter(is_verified=True, created_at__lt=this_month_start).count()
    active_new = Business.objects.filter(is_verified=True, created_at__gte=last_month_start, created_at__lt=this_month_start).count()
    active_growth = round((active_new / max(active_before - active_new, 1)) * 100) if active_before else 0

    total_customers = Customer.objects.count()
    cust_before = Customer.objects.filter(created_at__lt=this_month_start).count()
    cust_new = Customer.objects.filter(created_at__gte=last_month_start, created_at__lt=this_month_start).count()
    cust_growth = round((cust_new / max(cust_before - cust_new, 1)) * 100) if cust_before else 0

    inactive_accounts = Customer.objects.filter(status='inactive').count() + User.objects.filter(is_active=False).count()
    inactive_before = User.objects.filter(is_active=False, created_at__lt=this_month_start).count()
    inactive_new = User.objects.filter(is_active=False, created_at__gte=last_month_start, created_at__lt=this_month_start).count()
    inactive_growth = round((inactive_new / max(inactive_before - inactive_new, 1)) * 100) if inactive_before else 0

    # ── Business Owners list ──
    biz_filter = request.GET.get('biz_filter', 'all')
    businesses_qs = Business.objects.select_related('user').order_by('-created_at')
    if biz_filter == 'active':
        businesses_qs = businesses_qs.filter(is_verified=True, user__is_active=True)
    elif biz_filter == 'inactive':
        businesses_qs = businesses_qs.filter(Q(is_verified=False) | Q(user__is_active=False))
    elif biz_filter == 'pending':
        businesses_qs = businesses_qs.filter(is_verified=False, user__is_active=True)

    businesses = []
    for biz in businesses_qs[:6]:
        if biz.is_verified and biz.user.is_active:
            biz_status = 'active'
        elif not biz.user.is_active:
            biz_status = 'inactive'
        else:
            biz_status = 'pending'
        businesses.append({
            'business_id': biz.business_id,
            'business_name': biz.business_name,
            'owner_name': biz.user.full_name,
            'is_verified': biz.is_verified,
            'is_active': biz.user.is_active,
            'status': biz_status,
            'user_id': biz.user.user_id,
        })

    # ── Customer Accounts list ──
    cust_search = request.GET.get('cust_search', '').strip()
    customers_qs = Customer.objects.select_related('user').order_by('-created_at')
    if cust_search:
        customers_qs = customers_qs.filter(
            Q(user__full_name__icontains=cust_search) |
            Q(user__email__icontains=cust_search) |
            Q(user__phone_number__icontains=cust_search)
        )

    customers = []
    for cust in customers_qs[:5]:
        # Calculate total spent
        relationships = CustomerBusinessRelationship.objects.filter(customer=cust)
        total_spent = Transaction.objects.filter(
            relationship__in=relationships, amount__gt=0
        ).aggregate(total=Sum('amount'))['total'] or 0

        customers.append({
            'customer_id': cust.customer_id,
            'full_name': cust.user.full_name,
            'email': cust.user.email,
            'profile_picture': cust.user.profile_picture.url if cust.user.profile_picture else None,
            'member_since': cust.created_at.strftime('%b %Y'),
            'total_spent': float(total_spent),
            'status': cust.status,
            'user_id': cust.user.user_id,
        })

    # ── Roles list ──
    roles = []
    for role in Role.objects.all():
        user_count = UserRole.objects.filter(role=role).count()
        # Assign description based on role name
        if 'admin' in role.name.lower() or 'super' in role.name.lower():
            description = 'Full system access'
            icon_color = '#ef4444'
            permissions = ['All Permissions']
        elif 'manager' in role.name.lower():
            description = 'Department management'
            icon_color = '#f59e0b'
            permissions = ['User Management', 'Reports']
        elif 'support' in role.name.lower() or 'agent' in role.name.lower():
            description = 'Customer support'
            icon_color = '#3b82f6'
            permissions = ['Ticket Management']
        elif 'business' in role.name.lower():
            description = 'Business account access'
            icon_color = '#00d09e'
            permissions = ['Business Dashboard']
        elif 'customer' in role.name.lower():
            description = 'Customer account access'
            icon_color = '#8b5cf6'
            permissions = ['Customer Dashboard']
        else:
            description = 'Custom role'
            icon_color = '#6b7280'
            permissions = [role.name]

        roles.append({
            'role_id': role.role_id,
            'name': role.name,
            'description': description,
            'icon_color': icon_color,
            'permissions': permissions,
            'user_count': user_count,
        })

    # ── Recent Support Tickets ──
    recent_tickets = []
    for ticket in SupportTicket.objects.select_related('user').order_by('-created_at')[:5]:
        delta = now - ticket.created_at
        if delta.days > 0:
            time_ago = f"{delta.days} day{'s' if delta.days > 1 else ''} ago"
        elif delta.seconds >= 3600:
            hours = delta.seconds // 3600
            time_ago = f"{hours} hour{'s' if hours > 1 else ''} ago"
        elif delta.seconds >= 60:
            minutes = delta.seconds // 60
            time_ago = f"{minutes} minute{'s' if minutes > 1 else ''} ago"
        else:
            time_ago = "Just now"

        recent_tickets.append({
            'id': ticket.id,
            'subject': ticket.subject,
            'category': ticket.get_category_display(),
            'description': ticket.description[:60] + ('...' if len(ticket.description) > 60 else ''),
            'priority': ticket.priority,
            'priority_display': ticket.get_priority_display(),
            'status': ticket.status,
            'status_display': ticket.get_status_display(),
            'user_name': ticket.user.full_name,
            'user_initial': ticket.user.full_name[0].upper() if ticket.user.full_name else 'U',
            'time_ago': time_ago,
        })

    # Urgent ticket count (for notification badge)
    urgent_tickets = SupportTicket.objects.filter(
        Q(priority='urgent') | Q(priority='high'),
        status__in=['open', 'in_progress']
    ).count()

    context = {
        'total_business_owners': total_business_owners,
        'biz_growth': biz_growth,
        'active_accounts': active_accounts,
        'active_growth': active_growth,
        'total_customers': total_customers,
        'cust_growth': cust_growth,
        'inactive_accounts': inactive_accounts,
        'inactive_growth': inactive_growth,

        'businesses': businesses,
        'biz_filter': biz_filter,
        'customers': customers,
        'cust_search': cust_search,

        'roles': roles,
        'recent_tickets': recent_tickets,
        'urgent_tickets': urgent_tickets,
        'admin_user': request.user,
    }
    return render(request, 'admin_user_management.html', context)


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
