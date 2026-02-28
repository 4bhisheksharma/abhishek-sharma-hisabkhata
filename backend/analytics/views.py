from django.shortcuts import render, redirect
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth import logout as auth_logout
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


def admin_logout_view(request):
    """Log the admin user out and redirect to login page."""
    auth_logout(request)
    return redirect('admin:login')


def admin_index_redirect(request):
    """Redirect /admin/ to the custom dashboard."""
    return redirect('admin_dashboard')


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
    recent_tickets_raw = SupportTicket.objects.select_related('user').order_by('-created_at')[:5]
    recent_transactions = Transaction.objects.select_related(
        'relationship__customer__user', 'relationship__business'
    ).order_by('-created_at')[:5]

    # Build recent tickets list for dashboard
    recent_tickets = []
    for ticket in recent_tickets_raw:
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
    for ticket in recent_tickets_raw:
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
        'recent_tickets': recent_tickets,
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
            biz_status = 'verified'
            biz_status_label = 'Verified'
        elif not biz.user.is_active:
            biz_status = 'not-verified'
            biz_status_label = 'Not Verified'
        else:
            biz_status = 'pending'
            biz_status_label = 'Pending'
        businesses.append({
            'business_id': biz.business_id,
            'business_name': biz.business_name,
            'owner_name': biz.user.full_name,
            'is_verified': biz.is_verified,
            'is_active': biz.user.is_active,
            'status': biz_status,
            'status_label': biz_status_label,
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


class AdminToggleBusinessVerifiedView(APIView):
    """API endpoint to toggle business verified status."""
    permission_classes = [IsAdminUser]

    def post(self, request, business_id):
        try:
            business = Business.objects.get(business_id=business_id)
            business.is_verified = not business.is_verified
            business.save(update_fields=['is_verified', 'updated_at'])
            return Response({
                'status': 200,
                'message': f'Business {business.business_name} is now {"verified" if business.is_verified else "not verified"}.',
                'is_verified': business.is_verified,
            })
        except Business.DoesNotExist:
            return Response({'status': 404, 'message': 'Business not found.'}, status=status.HTTP_404_NOT_FOUND)


class AdminToggleUserActiveView(APIView):
    """API endpoint to toggle user active/inactive status."""
    permission_classes = [IsAdminUser]

    def post(self, request, user_id):
        try:
            user = User.objects.get(user_id=user_id)
            if user.is_superuser:
                return Response({'status': 403, 'message': 'Cannot deactivate superuser.'}, status=status.HTTP_403_FORBIDDEN)
            user.is_active = not user.is_active
            user.save(update_fields=['is_active', 'updated_at'])
            return Response({
                'status': 200,
                'message': f'User {user.full_name} is now {"active" if user.is_active else "inactive"}.',
                'is_active': user.is_active,
            })
        except User.DoesNotExist:
            return Response({'status': 404, 'message': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)


class AdminUserListView(APIView):
    """API endpoint to list all users with filtering."""
    permission_classes = [IsAdminUser]

    def get(self, request):
        role_filter = request.query_params.get('role', None)
        status_filter = request.query_params.get('status', None)
        search = request.query_params.get('search', '').strip()

        users_qs = User.objects.all().order_by('-created_at')

        if search:
            users_qs = users_qs.filter(
                Q(full_name__icontains=search) |
                Q(email__icontains=search) |
                Q(phone_number__icontains=search)
            )
        if status_filter == 'active':
            users_qs = users_qs.filter(is_active=True)
        elif status_filter == 'inactive':
            users_qs = users_qs.filter(is_active=False)

        if role_filter:
            users_qs = users_qs.filter(user_roles__role__name__iexact=role_filter)

        users = []
        for u in users_qs[:50]:
            roles = list(u.user_roles.values_list('role__name', flat=True))
            users.append({
                'user_id': u.user_id,
                'full_name': u.full_name,
                'email': u.email,
                'phone_number': u.phone_number,
                'is_active': u.is_active,
                'is_staff': u.is_staff,
                'is_superuser': u.is_superuser,
                'roles': roles,
                'created_at': u.created_at.isoformat(),
            })
        return Response({'status': 200, 'data': users})


class AdminDeleteUserView(APIView):
    """API endpoint to delete a user account."""
    permission_classes = [IsAdminUser]

    def delete(self, request, user_id):
        try:
            user = User.objects.get(user_id=user_id)
            if user.is_superuser:
                return Response({'status': 403, 'message': 'Cannot delete superuser.'}, status=status.HTTP_403_FORBIDDEN)
            name = user.full_name
            user.delete()
            return Response({'status': 200, 'message': f'User {name} has been deleted.'})
        except User.DoesNotExist:
            return Response({'status': 404, 'message': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)


class AdminUpdateTicketStatusView(APIView):
    """API endpoint to update ticket status from admin panel."""
    permission_classes = [IsAdminUser]

    def patch(self, request, ticket_id):
        try:
            ticket = SupportTicket.objects.get(id=ticket_id)
            new_status = request.data.get('status')
            admin_response = request.data.get('admin_response')

            if new_status:
                if new_status not in dict(SupportTicket.STATUS_CHOICES):
                    return Response({'status': 400, 'message': 'Invalid status.'}, status=status.HTTP_400_BAD_REQUEST)
                if new_status in ['resolved', 'closed'] and ticket.status not in ['resolved', 'closed']:
                    ticket.resolved_at = timezone.now()
                    ticket.resolved_by = request.user
                ticket.status = new_status

            if admin_response:
                ticket.admin_response = admin_response

            ticket.save()
            return Response({
                'status': 200,
                'message': f'Ticket updated to {ticket.get_status_display()}.',
                'ticket_status': ticket.status,
                'ticket_status_display': ticket.get_status_display(),
            })
        except SupportTicket.DoesNotExist:
            return Response({'status': 404, 'message': 'Ticket not found.'}, status=status.HTTP_404_NOT_FOUND)


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


# ═══════════════════════════════════════════════════════════════
#  ADMIN PAGES: All Businesses / All Customers / Analytics / Communication
# ═══════════════════════════════════════════════════════════════

def _time_ago(dt):
    """Helper to format a datetime as a human-readable 'X ago' string."""
    now = timezone.now()
    delta = now - dt
    if delta.days > 0:
        return f"{delta.days} day{'s' if delta.days > 1 else ''} ago"
    elif delta.seconds >= 3600:
        hours = delta.seconds // 3600
        return f"{hours} hour{'s' if hours > 1 else ''} ago"
    elif delta.seconds >= 60:
        minutes = delta.seconds // 60
        return f"{minutes} minute{'s' if minutes > 1 else ''} ago"
    return "Just now"


class AdminVerificationRequestsView(APIView):
    """API endpoint to list and review business verification requests."""
    permission_classes = [IsAdminUser]

    def get(self, request):
        """List all verification requests, optionally filtered by status."""
        from business_dashboard.models import BusinessVerificationRequest
        status_filter = request.query_params.get('status', None)
        qs = BusinessVerificationRequest.objects.select_related(
            'business', 'business__user', 'reviewed_by'
        ).order_by('-created_at')
        if status_filter in ('pending', 'approved', 'rejected'):
            qs = qs.filter(status=status_filter)

        data = []
        for req in qs:
            data.append({
                'id': req.id,
                'business_id': req.business.business_id,
                'business_name': req.business.business_name,
                'owner_name': req.business.user.full_name,
                'owner_email': req.business.user.email,
                'document': req.document.url if req.document else None,
                'document_type': req.document_type,
                'note': req.note,
                'status': req.status,
                'admin_remarks': req.admin_remarks,
                'reviewed_by': req.reviewed_by.full_name if req.reviewed_by else None,
                'reviewed_at': req.reviewed_at.isoformat() if req.reviewed_at else None,
                'created_at': req.created_at.isoformat(),
            })

        return Response({'status': 200, 'data': data})


class AdminReviewVerificationView(APIView):
    """API endpoint for admin to approve or reject a verification request."""
    permission_classes = [IsAdminUser]

    def post(self, request, request_id):
        from business_dashboard.models import BusinessVerificationRequest
        try:
            ver_req = BusinessVerificationRequest.objects.select_related('business').get(id=request_id)
        except BusinessVerificationRequest.DoesNotExist:
            return Response({'status': 404, 'message': 'Verification request not found.'}, status=status.HTTP_404_NOT_FOUND)

        action = request.data.get('action')  # 'approve' or 'reject'
        remarks = request.data.get('remarks', '')

        if action not in ('approve', 'reject'):
            return Response({'status': 400, 'message': 'Action must be "approve" or "reject".'}, status=status.HTTP_400_BAD_REQUEST)

        ver_req.status = 'approved' if action == 'approve' else 'rejected'
        ver_req.admin_remarks = remarks
        ver_req.reviewed_by = request.user
        ver_req.reviewed_at = timezone.now()
        ver_req.save()

        if action == 'approve':
            ver_req.business.is_verified = True
            ver_req.business.save(update_fields=['is_verified', 'updated_at'])

        return Response({
            'status': 200,
            'message': f'Verification request {action}d successfully.',
            'is_verified': ver_req.business.is_verified,
        })


@staff_member_required
def admin_all_businesses_view(request):
    """Full listing of all businesses with search, filter and pagination."""
    from django.core.paginator import Paginator

    search = request.GET.get('search', '').strip()
    status_filter = request.GET.get('status', 'all')

    qs = Business.objects.select_related('user').order_by('-created_at')

    if search:
        qs = qs.filter(
            Q(business_name__icontains=search) |
            Q(user__full_name__icontains=search) |
            Q(user__email__icontains=search)
        )
    if status_filter == 'verified':
        qs = qs.filter(is_verified=True, user__is_active=True)
    elif status_filter == 'not_verified':
        qs = qs.filter(Q(is_verified=False) | Q(user__is_active=False))
    elif status_filter == 'pending':
        qs = qs.filter(is_verified=False, user__is_active=True)

    paginator = Paginator(qs, 15)
    page_number = request.GET.get('page', 1)
    page_obj = paginator.get_page(page_number)

    businesses = []
    for biz in page_obj:
        if biz.is_verified and biz.user.is_active:
            biz_status, biz_label = 'verified', 'Verified'
        elif not biz.user.is_active:
            biz_status, biz_label = 'not-verified', 'Not Verified'
        else:
            biz_status, biz_label = 'pending', 'Pending'

        # Count customers for this business
        cust_count = CustomerBusinessRelationship.objects.filter(business=biz).count()
        total_revenue = Transaction.objects.filter(
            relationship__business=biz, amount__gt=0
        ).aggregate(total=Sum('amount'))['total'] or 0

        businesses.append({
            'business_id': biz.business_id,
            'business_name': biz.business_name,
            'owner_name': biz.user.full_name,
            'email': biz.user.email,
            'phone': biz.user.phone_number,
            'is_verified': biz.is_verified,
            'status': biz_status,
            'status_label': biz_label,
            'customer_count': cust_count,
            'total_revenue': float(total_revenue),
            'created_at': biz.created_at.strftime('%b %d, %Y'),
        })

    # Stats
    total_count = Business.objects.count()
    verified_count = Business.objects.filter(is_verified=True).count()
    pending_count = Business.objects.filter(is_verified=False, user__is_active=True).count()

    urgent_tickets = SupportTicket.objects.filter(
        Q(priority='urgent') | Q(priority='high'),
        status__in=['open', 'in_progress']
    ).count()

    context = {
        'businesses': businesses,
        'page_obj': page_obj,
        'search': search,
        'status_filter': status_filter,
        'total_count': total_count,
        'verified_count': verified_count,
        'pending_count': pending_count,
        'unverified_count': total_count - verified_count,
        'urgent_tickets': urgent_tickets,
        'admin_user': request.user,
    }

    # Verification Requests
    from business_dashboard.models import BusinessVerificationRequest
    ver_filter = request.GET.get('ver', 'all')
    ver_qs = BusinessVerificationRequest.objects.select_related(
        'business', 'business__user'
    ).order_by('-created_at')
    if ver_filter in ('pending', 'approved', 'rejected'):
        ver_qs = ver_qs.filter(status=ver_filter)

    verification_requests = []
    for vr in ver_qs[:20]:
        verification_requests.append({
            'id': vr.id,
            'business_name': vr.business.business_name,
            'owner_name': vr.business.user.full_name,
            'owner_email': vr.business.user.email,
            'document_url': vr.document.url if vr.document else None,
            'document_type': vr.document_type,
            'note': vr.note or '',
            'status': vr.status,
            'status_label': vr.get_status_display(),
            'admin_remarks': vr.admin_remarks or '',
            'created_at': vr.created_at.strftime('%b %d, %Y'),
        })
    context['verification_requests'] = verification_requests
    context['ver_filter'] = ver_filter

    return render(request, 'admin_all_businesses.html', context)


@staff_member_required
def admin_all_customers_view(request):
    """Full listing of all customers with search, filter and pagination."""
    from django.core.paginator import Paginator

    search = request.GET.get('search', '').strip()
    status_filter = request.GET.get('status', 'all')

    qs = Customer.objects.select_related('user').order_by('-created_at')

    if search:
        qs = qs.filter(
            Q(user__full_name__icontains=search) |
            Q(user__email__icontains=search) |
            Q(user__phone_number__icontains=search)
        )
    if status_filter in ('active', 'inactive', 'suspended'):
        qs = qs.filter(status=status_filter)

    paginator = Paginator(qs, 15)
    page_number = request.GET.get('page', 1)
    page_obj = paginator.get_page(page_number)

    customers = []
    for cust in page_obj:
        relationships = CustomerBusinessRelationship.objects.filter(customer=cust)
        total_spent = Transaction.objects.filter(
            relationship__in=relationships, amount__gt=0
        ).aggregate(total=Sum('amount'))['total'] or 0

        customers.append({
            'customer_id': cust.customer_id,
            'full_name': cust.user.full_name,
            'email': cust.user.email,
            'phone': cust.user.phone_number,
            'profile_picture': cust.user.profile_picture.url if cust.user.profile_picture else None,
            'status': cust.status,
            'status_label': cust.get_status_display() if hasattr(cust, 'get_status_display') else cust.status.title(),
            'monthly_limit': float(cust.monthly_limit) if cust.monthly_limit else 0,
            'total_spent': float(total_spent),
            'business_count': relationships.count(),
            'member_since': cust.created_at.strftime('%b %d, %Y'),
        })

    total_count = Customer.objects.count()
    active_count = Customer.objects.filter(status='active').count()
    inactive_count = Customer.objects.filter(status='inactive').count()
    suspended_count = Customer.objects.filter(status='suspended').count()

    urgent_tickets = SupportTicket.objects.filter(
        Q(priority='urgent') | Q(priority='high'),
        status__in=['open', 'in_progress']
    ).count()

    context = {
        'customers': customers,
        'page_obj': page_obj,
        'search': search,
        'status_filter': status_filter,
        'total_count': total_count,
        'active_count': active_count,
        'inactive_count': inactive_count,
        'suspended_count': suspended_count,
        'urgent_tickets': urgent_tickets,
        'admin_user': request.user,
    }
    return render(request, 'admin_all_customers.html', context)


@staff_member_required
def admin_analytics_view(request):
    """Analytics dashboard with platform metrics, activity feed and fraud detection."""
    now = timezone.now()
    last_month_start = (now - relativedelta(months=1)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    this_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # ── Stats ──
    total_users = User.objects.filter(is_active=True).count()
    total_businesses = Business.objects.count()
    total_customers = Customer.objects.count()
    total_transactions = Transaction.objects.count()
    total_revenue = float(
        Transaction.objects.filter(amount__gt=0).aggregate(total=Sum('amount'))['total'] or 0
    )
    open_tickets = SupportTicket.objects.filter(status__in=['open', 'in_progress']).count()

    # Growth percentages
    users_before = User.objects.filter(is_active=True, created_at__lt=this_month_start).count()
    users_new = User.objects.filter(is_active=True, created_at__gte=last_month_start, created_at__lt=this_month_start).count()
    user_growth = round((users_new / max(users_before - users_new, 1)) * 100) if users_before else 0

    txn_before = Transaction.objects.filter(created_at__lt=this_month_start).count()
    txn_new = Transaction.objects.filter(created_at__gte=last_month_start, created_at__lt=this_month_start).count()
    txn_growth = round((txn_new / max(txn_before - txn_new, 1)) * 100) if txn_before else 0

    # ── Monthly platform metrics (last 6 months) ──
    six_months_ago = (now - relativedelta(months=5)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    metric_labels = []
    biz_data = []
    cust_data = []
    txn_data = []
    for i in range(6):
        month_date = six_months_ago + relativedelta(months=i)
        next_month = month_date + relativedelta(months=1)
        metric_labels.append(month_date.strftime('%b'))
        biz_data.append(Business.objects.filter(created_at__gte=month_date, created_at__lt=next_month).count())
        cust_data.append(Customer.objects.filter(created_at__gte=month_date, created_at__lt=next_month).count())
        txn_data.append(Transaction.objects.filter(created_at__gte=month_date, created_at__lt=next_month).count())

    # ── Recent platform activity ──
    recent_businesses = Business.objects.select_related('user').order_by('-created_at')[:5]
    recent_tickets_raw = SupportTicket.objects.select_related('user').order_by('-created_at')[:5]
    recent_txn = Transaction.objects.select_related(
        'relationship__customer__user', 'relationship__business'
    ).order_by('-created_at')[:5]

    activities = []
    for biz in recent_businesses:
        activities.append({
            'icon': 'fa-store', 'color': '#00d09e',
            'text': f'New business registered: {biz.business_name}',
            'time': biz.created_at, 'time_ago': _time_ago(biz.created_at),
        })
    for t in recent_txn:
        activities.append({
            'icon': 'fa-right-left', 'color': '#3b82f6',
            'text': f'Transaction of Rs.{t.amount} — {t.relationship.business.business_name}',
            'time': t.created_at, 'time_ago': _time_ago(t.created_at),
        })
    for ticket in recent_tickets_raw:
        activities.append({
            'icon': 'fa-headset', 'color': '#ef4444',
            'text': f'Ticket: {ticket.subject} ({ticket.get_priority_display()})',
            'time': ticket.created_at, 'time_ago': _time_ago(ticket.created_at),
        })
    activities.sort(key=lambda x: x['time'], reverse=True)
    activities = activities[:8]

    # ── Fraud detection section (meaningful alerts) ──
    fraud_alerts = []
    inactive_users = User.objects.filter(is_active=False).count()
    if inactive_users:
        fraud_alerts.append({
            'icon': 'fa-user-slash', 'severity': 'medium',
            'title': 'Inactive Accounts',
            'desc': f'{inactive_users} deactivated user account{"s" if inactive_users > 1 else ""}',
        })
    suspended_custs = Customer.objects.filter(status='suspended').count()
    if suspended_custs:
        fraud_alerts.append({
            'icon': 'fa-ban', 'severity': 'high',
            'title': 'Suspended Customers',
            'desc': f'{suspended_custs} customer account{"s" if suspended_custs > 1 else ""} suspended',
        })
    unverified_biz = Business.objects.filter(is_verified=False).count()
    if unverified_biz:
        fraud_alerts.append({
            'icon': 'fa-shield-halved', 'severity': 'low',
            'title': 'Unverified Businesses',
            'desc': f'{unverified_biz} business{"es" if unverified_biz > 1 else ""} pending verification',
        })
    urgent_tickets = SupportTicket.objects.filter(priority='urgent', status__in=['open', 'in_progress']).count()
    if urgent_tickets:
        fraud_alerts.append({
            'icon': 'fa-exclamation-triangle', 'severity': 'high',
            'title': 'Urgent Support Tickets',
            'desc': f'{urgent_tickets} urgent ticket{"s" if urgent_tickets > 1 else ""} unresolved',
        })
    if not fraud_alerts:
        fraud_alerts.append({
            'icon': 'fa-check-circle', 'severity': 'low',
            'title': 'All Clear',
            'desc': 'No alerts at this time',
        })

    all_urgent_tickets = SupportTicket.objects.filter(
        Q(priority='urgent') | Q(priority='high'),
        status__in=['open', 'in_progress']
    ).count()

    context = {
        'total_users': total_users,
        'user_growth': user_growth,
        'total_businesses': total_businesses,
        'total_customers': total_customers,
        'total_transactions': total_transactions,
        'txn_growth': txn_growth,
        'total_revenue': total_revenue,
        'open_tickets': open_tickets,

        'metric_labels': json.dumps(metric_labels),
        'biz_data': json.dumps(biz_data),
        'cust_data': json.dumps(cust_data),
        'txn_data': json.dumps(txn_data),

        'activities': activities,
        'fraud_alerts': fraud_alerts,
        'urgent_tickets': all_urgent_tickets,
        'admin_user': request.user,
    }
    return render(request, 'admin_analytics.html', context)


@staff_member_required
def admin_communication_view(request):
    """Communication & Broadcast page."""
    # Recent broadcasts (notifications sent by admin users)
    admin_users = User.objects.filter(is_superuser=True)
    recent_broadcasts = Notification.objects.filter(
        sender__in=admin_users
    ).order_by('-created_at')[:10]

    broadcasts = []
    for notif in recent_broadcasts:
        broadcasts.append({
            'id': notif.notification_id,
            'title': notif.title,
            'message': notif.message[:80] + ('...' if len(notif.message) > 80 else ''),
            'type': notif.type,
            'receiver_name': notif.receiver.full_name,
            'is_read': notif.is_read,
            'created_at': notif.created_at.strftime('%b %d, %Y %I:%M %p'),
            'time_ago': _time_ago(notif.created_at),
        })

    total_sent = Notification.objects.filter(sender__in=admin_users).count()
    total_read = Notification.objects.filter(sender__in=admin_users, is_read=True).count()
    total_unread = total_sent - total_read

    urgent_tickets = SupportTicket.objects.filter(
        Q(priority='urgent') | Q(priority='high'),
        status__in=['open', 'in_progress']
    ).count()

    context = {
        'broadcasts': broadcasts,
        'total_sent': total_sent,
        'total_read': total_read,
        'total_unread': total_unread,
        'urgent_tickets': urgent_tickets,
        'admin_user': request.user,
    }
    return render(request, 'admin_communication.html', context)


class AdminSendBroadcastView(APIView):
    """API endpoint to send broadcast notification to users."""
    permission_classes = [IsAdminUser]

    def post(self, request):
        title = request.data.get('title', '').strip()
        message = request.data.get('message', '').strip()
        notif_type = request.data.get('type', 'announcement')
        target = request.data.get('target', 'all')  # all / businesses / customers

        if not title or not message:
            return Response({'status': 400, 'message': 'Title and message are required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Determine target users
        if target == 'businesses':
            receivers = User.objects.filter(
                business_profile__isnull=False, is_active=True
            )
        elif target == 'customers':
            receivers = User.objects.filter(
                customer_profile__isnull=False, is_active=True
            )
        else:
            receivers = User.objects.filter(is_active=True).exclude(pk=request.user.pk)

        created = 0
        for user in receivers:
            Notification.objects.create(
                sender=request.user,
                receiver=user,
                title=title,
                message=message,
                type=notif_type,
            )
            created += 1

        return Response({
            'status': 200,
            'message': f'Broadcast sent to {created} user{"s" if created != 1 else ""}.',
            'count': created,
        })


class AdminTicketDetailView(APIView):
    """API endpoint to get full ticket details including admin response."""
    permission_classes = [IsAdminUser]

    def get(self, request, ticket_id):
        try:
            ticket = SupportTicket.objects.select_related('user', 'resolved_by').get(id=ticket_id)
            return Response({
                'status': 200,
                'data': {
                    'id': ticket.id,
                    'subject': ticket.subject,
                    'description': ticket.description,
                    'category': ticket.get_category_display(),
                    'priority': ticket.priority,
                    'priority_display': ticket.get_priority_display(),
                    'status': ticket.status,
                    'status_display': ticket.get_status_display(),
                    'admin_response': ticket.admin_response or '',
                    'user_name': ticket.user.full_name,
                    'user_email': ticket.user.email,
                    'resolved_by': ticket.resolved_by.full_name if ticket.resolved_by else None,
                    'resolved_at': ticket.resolved_at.isoformat() if ticket.resolved_at else None,
                    'created_at': ticket.created_at.isoformat(),
                }
            })
        except SupportTicket.DoesNotExist:
            return Response({'status': 404, 'message': 'Ticket not found.'}, status=status.HTTP_404_NOT_FOUND)
