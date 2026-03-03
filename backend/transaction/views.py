from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db import transaction as db_transaction
from django.db.models import Sum, Count
from django.db.models.functions import TruncDate
from collections import defaultdict

from .models import Transaction, Favorite
from .serializers import (
    TransactionSerializer,
    CreateTransactionSerializer,
    ConnectedUserDetailsSerializer,
    FavoriteSerializer,
    AddFavoriteSerializer,
)
from customer_dashboard.models import Customer, CustomerBusinessRelationship
from business_dashboard.models import Business
from notification.services import (
    notify_transaction_added,
    notify_payment_received,
    notify_monthly_limit_exceeded,
    notify_favorite_added,
)

import logging

logger = logging.getLogger(__name__)


class TransactionViewSet(viewsets.ModelViewSet):
    """ViewSet for managing transactions"""
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return transactions for relationships the user is part of"""
        user = self.request.user
        relationship_ids = []
        
        if hasattr(user, 'customer_profile'):
            customer_relationships = CustomerBusinessRelationship.objects.filter(
                customer=user.customer_profile
            ).values_list('relationship_id', flat=True)
            relationship_ids.extend(customer_relationships)
        
        if hasattr(user, 'business_profile'):
            business_relationships = CustomerBusinessRelationship.objects.filter(
                business=user.business_profile
            ).values_list('relationship_id', flat=True)
            relationship_ids.extend(business_relationships)
        
        return Transaction.objects.filter(
            relationship_id__in=relationship_ids
        ).order_by('-transaction_date')
    
    def create(self, request, *args, **kwargs):
        """Create a new transaction"""
        serializer = CreateTransactionSerializer(
            data=request.data, 
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        relationship = CustomerBusinessRelationship.objects.get(
            relationship_id=data['relationship_id']
        )
        
        with db_transaction.atomic():
            # Determine the amount based on transaction type
            # Payments and refunds should be negative (reduce debt)
            # Purchases and credits should be positive (increase debt)
            transaction_type = data.get('transaction_type', 'purchase')
            amount = data['amount']
            
            if transaction_type in ['payment', 'refund']:
                # Convert to negative to reduce the pending due
                amount = -abs(amount)
            else:
                # Purchase, credit, adjustment - keep positive
                amount = abs(amount)
            
            # Create the transaction
            new_transaction = Transaction.objects.create(
                relationship=relationship,
                amount=amount,
                transaction_type=transaction_type,
                description=data.get('description', ''),
            )
            
            # Update the pending due based on transaction type
            relationship.update_pending_due()

        # --- Notifications ---
        try:
            current_user = request.user
            customer_user = relationship.customer.user
            business_user = relationship.business.user

            # Determine recipient (the "other" party)
            if current_user == customer_user:
                other_user = business_user
            else:
                other_user = customer_user

            if transaction_type in ['payment', 'refund']:
                # Customer made a payment → notify business
                notify_payment_received(
                    payer_user=current_user,
                    business_user=other_user,
                    amount=amount,
                    relationship_id=relationship.relationship_id,
                )
            else:
                # Business added a purchase/credit → notify customer
                notify_transaction_added(
                    sender_user=current_user,
                    receiver_user=other_user,
                    amount=amount,
                    transaction_type=transaction_type,
                    relationship_id=relationship.relationship_id,
                    description=data.get('description', ''),
                )

            # Check monthly limit for the customer after any transaction
            customer = relationship.customer
            if customer.monthly_limit > 0:
                overview = Customer.objects.get_monthly_spending_overview(customer)
                if overview['is_over_budget']:
                    notify_monthly_limit_exceeded(
                        customer_user=customer_user,
                        total_spent=overview['total_spent'],
                        monthly_limit=float(customer.monthly_limit),
                    )
        except Exception as e:
            logger.error(f"Transaction notification error: {e}")
        
        return Response(
            TransactionSerializer(new_transaction).data,
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=False, methods=['get'])
    def by_relationship(self, request):
        """Get transactions for a specific relationship"""
        relationship_id = request.query_params.get('relationship_id')
        if not relationship_id:
            return Response(
                {"error": "relationship_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Verify user has access to this relationship
        user = request.user
        try:
            relationship = CustomerBusinessRelationship.objects.get(
                relationship_id=relationship_id
            )
        except CustomerBusinessRelationship.DoesNotExist:
            return Response(
                {"error": "Relationship not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        is_customer = hasattr(user, 'customer_profile') and relationship.customer == user.customer_profile
        is_business = hasattr(user, 'business_profile') and relationship.business == user.business_profile
        
        if not is_customer and not is_business:
            return Response(
                {"error": "You don't have access to this relationship"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        transactions = Transaction.objects.filter(
            relationship=relationship
        ).order_by('-transaction_date')
        
        return Response(TransactionSerializer(transactions, many=True).data)


class ConnectedUserDetailsViewSet(viewsets.ViewSet):
    """ViewSet for getting connected user details"""
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'], url_path='(?P<relationship_id>[^/.]+)')
    def details(self, request, relationship_id=None):
        """
        Get detailed information about a connected user
        
        Returns user profile, financial summary (to_pay, paid), and transaction history
        """
        user = request.user
        
        try:
            relationship = CustomerBusinessRelationship.objects.get(
                relationship_id=relationship_id
            )
        except CustomerBusinessRelationship.DoesNotExist:
            return Response(
                {"error": "Relationship not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Determine if current user is customer or business
        is_current_user_customer = hasattr(user, 'customer_profile') and \
            relationship.customer == user.customer_profile
        is_current_user_business = hasattr(user, 'business_profile') and \
            relationship.business == user.business_profile
        
        if not is_current_user_customer and not is_current_user_business:
            return Response(
                {"error": "You don't have access to this relationship"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Get the "other" user in the relationship
        if is_current_user_customer:
            # Current user is customer, return business details
            other_business = relationship.business
            other_user = other_business.user
            
            # Check if business is favorited
            is_favorite = Favorite.objects.filter(
                customer=user.customer_profile,
                business=other_business
            ).exists()
            
            data = {
                'user_id': other_user.id,
                'email': other_user.email,
                'phone_number': other_user.phone_number,
                'full_name': other_user.full_name,
                'profile_picture': other_user.profile_picture.url if other_user.profile_picture else None,
                'is_business': True,
                'business_id': other_business.business_id,
                'business_name': other_business.business_name,
                'customer_id': None,
                'relationship_id': relationship.relationship_id,
                'connected_at': relationship.created_at,
                'to_pay': relationship.pending_due,  # What customer owes to business
                'total_paid': relationship.get_total_paid(),
                'is_favorite': is_favorite,
                'latitude': other_business.latitude,
                'longitude': other_business.longitude,
                'address': other_business.address,
            }
        else:
            # Current user is business, return customer details
            other_customer = relationship.customer
            other_user = other_customer.user
            
            data = {
                'user_id': other_user.id,
                'email': other_user.email,
                'phone_number': other_user.phone_number,
                'full_name': other_user.full_name,
                'profile_picture': other_user.profile_picture.url if other_user.profile_picture else None,
                'is_business': False,
                'business_id': None,
                'business_name': None,
                'customer_id': other_customer.customer_id,
                'relationship_id': relationship.relationship_id,
                'connected_at': relationship.created_at,
                'to_pay': relationship.pending_due,  # What customer owes
                'total_paid': relationship.get_total_paid(),
                'is_favorite': False,  # Businesses don't have favorites
                'latitude': None,
                'longitude': None,
                'address': None,
            }
        
        # Get transactions for this relationship
        transactions = Transaction.objects.filter(
            relationship=relationship
        ).order_by('-transaction_date')
        
        data['transactions'] = TransactionSerializer(transactions, many=True).data
        
        return Response(ConnectedUserDetailsSerializer(data).data)


class FavoriteViewSet(viewsets.ModelViewSet):
    """ViewSet for managing favorite businesses (for customers only)"""
    serializer_class = FavoriteSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return favorites based on user type"""
        user = self.request.user
        
        # If user is a customer, return their favorite businesses
        if hasattr(user, 'customer_profile'):
            return Favorite.objects.filter(
                customer=user.customer_profile
            ).order_by('-created_at')
        
        # If user is a business, return customers who have favorited them
        elif hasattr(user, 'business_profile'):
            return Favorite.objects.filter(
                business=user.business_profile
            ).select_related('customer__user').order_by('-created_at')
        
        # Otherwise return empty queryset
        return Favorite.objects.none()
    
    def create(self, request, *args, **kwargs):
        """Add a business to favorites"""
        # Verify user is a customer
        if not hasattr(request.user, 'customer_profile'):
            return Response(
                {"error": "Only customers can add favorites"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = AddFavoriteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        business = get_object_or_404(
            Business, 
            business_id=serializer.validated_data['business_id']
        )
        customer = request.user.customer_profile
        
        # Check if already favorited
        if Favorite.objects.filter(customer=customer, business=business).exists():
            return Response(
                {"error": "Business is already in favorites"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        favorite = Favorite.objects.create(
            customer=customer,
            business=business
        )

        # Notify the business owner that they were favorited
        try:
            notify_favorite_added(
                customer_user=request.user,
                business_user=business.user,
            )
        except Exception as e:
            logger.error(f"Favorite notification error: {e}")
        
        return Response(
            FavoriteSerializer(favorite).data,
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=False, methods=['delete'], url_path='by-business/(?P<business_id>[^/.]+)')
    def remove_by_business(self, request, business_id=None):
        """Remove a business from favorites by business_id"""
        if not hasattr(request.user, 'customer_profile'):
            return Response(
                {"error": "Only customers can manage favorites"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            favorite = Favorite.objects.get(
                customer=request.user.customer_profile,
                business_id=business_id
            )
            favorite.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Favorite.DoesNotExist:
            return Response(
                {"error": "Favorite not found"},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['get'])
    def check(self, request):
        """Check if a business is favorited"""
        business_id = request.query_params.get('business_id')
        if not business_id:
            return Response(
                {"error": "business_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not hasattr(request.user, 'customer_profile'):
            return Response({"is_favorite": False})
        
        is_favorite = Favorite.objects.filter(
            customer=request.user.customer_profile,
            business_id=business_id
        ).exists()
        
        return Response({"is_favorite": is_favorite})


class TransactionActivityView(APIView):
    """
    Returns transaction activity grouped by date, showing which users
    the current user transacted with on each day.
    
    GET /transaction/activity/?days=30
    
    Response:
    [
        {
            "date": "2026-03-03",
            "total_amount": 1500.00,
            "transaction_count": 3,
            "users": [
                {
                    "relationship_id": 1,
                    "user_id": 5,
                    "display_name": "Ram's Shop",
                    "profile_picture": "/media/profile_pictures/...",
                    "is_business": true,
                    "amount_total": 1000.00,
                    "transaction_count": 2
                },
                ...
            ]
        },
        ...
    ]
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        days = int(request.query_params.get('days', 30))
        
        # Get all relationship IDs where the user is involved
        relationship_ids = []
        is_customer = hasattr(user, 'customer_profile')
        is_business = hasattr(user, 'business_profile')
        
        if is_customer:
            customer_rels = CustomerBusinessRelationship.objects.filter(
                customer=user.customer_profile
            ).values_list('relationship_id', flat=True)
            relationship_ids.extend(customer_rels)
        
        if is_business:
            business_rels = CustomerBusinessRelationship.objects.filter(
                business=user.business_profile
            ).values_list('relationship_id', flat=True)
            relationship_ids.extend(business_rels)
        
        if not relationship_ids:
            return Response([])
        
        # Get transactions within the specified days range
        from django.utils import timezone
        from datetime import timedelta
        
        cutoff_date = timezone.now() - timedelta(days=days)
        
        transactions = Transaction.objects.filter(
            relationship_id__in=relationship_ids,
            transaction_date__gte=cutoff_date
        ).select_related(
            'relationship__customer__user',
            'relationship__business__user',
            'relationship__business',
        ).order_by('-transaction_date')
        
        # Group by date, then by relationship
        date_groups = defaultdict(lambda: defaultdict(list))
        
        for txn in transactions:
            date_key = txn.transaction_date.date().isoformat()
            rel_id = txn.relationship_id
            date_groups[date_key][rel_id].append(txn)
        
        # Build response
        result = []
        for date_key in sorted(date_groups.keys(), reverse=True):
            rel_groups = date_groups[date_key]
            day_total = 0
            day_count = 0
            users_list = []
            
            for rel_id, txns in rel_groups.items():
                rel = txns[0].relationship
                
                # Determine the "other" user in the relationship
                if is_customer and rel.customer.user_id == user.id:
                    other_user = rel.business.user
                    display_name = rel.business.business_name
                    other_is_business = True
                    other_user_id = other_user.id
                elif is_business and rel.business.user_id == user.id:
                    other_user = rel.customer.user
                    display_name = other_user.full_name
                    other_is_business = False
                    other_user_id = other_user.id
                else:
                    continue
                
                profile_pic = None
                if other_user.profile_picture:
                    profile_pic = f"/media/{other_user.profile_picture}"
                
                amount_total = sum(abs(float(t.amount)) for t in txns)
                txn_count = len(txns)
                
                day_total += amount_total
                day_count += txn_count
                
                users_list.append({
                    'relationship_id': rel_id,
                    'user_id': other_user_id,
                    'display_name': display_name,
                    'profile_picture': profile_pic,
                    'is_business': other_is_business,
                    'amount_total': round(amount_total, 2),
                    'transaction_count': txn_count,
                })
            
            result.append({
                'date': date_key,
                'total_amount': round(day_total, 2),
                'transaction_count': day_count,
                'users': users_list,
            })
        
        return Response(result)
