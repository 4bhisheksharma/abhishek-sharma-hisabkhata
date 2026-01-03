from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db import transaction as db_transaction

from .models import Transaction, Favorite
from .serializers import (
    TransactionSerializer,
    CreateTransactionSerializer,
    ConnectedUserDetailsSerializer,
    FavoriteSerializer,
    AddFavoriteSerializer,
)
from customer_dashboard.models import CustomerBusinessRelationship
from business_dashboard.models import Business


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
            # Create the transaction
            new_transaction = Transaction.objects.create(
                relationship=relationship,
                amount=data['amount'],
                transaction_type=data.get('transaction_type', 'purchase'),
                description=data.get('description', ''),
            )
            
            # Update the pending due based on transaction type
            relationship.update_pending_due()
        
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
        """Return favorites for the current customer"""
        user = self.request.user
        if hasattr(user, 'customer_profile'):
            return Favorite.objects.filter(
                customer=user.customer_profile
            ).order_by('-created_at')
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
