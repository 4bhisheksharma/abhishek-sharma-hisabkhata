from rest_framework import serializers
from .models import Transaction, Favorite
from customer_dashboard.models import CustomerBusinessRelationship
from hisabauth.models import User


class TransactionSerializer(serializers.ModelSerializer):
    """Serializer for transaction details"""
    
    class Meta:
        model = Transaction
        fields = [
            'transaction_id',
            'amount',
            'transaction_type',
            'description',
            'transaction_date',
            'created_at',
        ]
        read_only_fields = ['transaction_id', 'created_at']


class CreateTransactionSerializer(serializers.Serializer):
    """Serializer for creating a new transaction"""
    relationship_id = serializers.IntegerField()
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    transaction_type = serializers.ChoiceField(
        choices=['purchase', 'payment', 'credit', 'refund', 'adjustment']
    )
    description = serializers.CharField(max_length=255, required=False, allow_blank=True)
    
    def validate_relationship_id(self, value):
        """Validate that relationship exists and user has access"""
        request = self.context.get('request')
        user = request.user
        
        try:
            relationship = CustomerBusinessRelationship.objects.get(relationship_id=value)
        except CustomerBusinessRelationship.DoesNotExist:
            raise serializers.ValidationError("Relationship not found")
        
        # Check if user is part of this relationship
        is_customer = hasattr(user, 'customer_profile') and relationship.customer == user.customer_profile
        is_business = hasattr(user, 'business_profile') and relationship.business == user.business_profile
        
        if not is_customer and not is_business:
            raise serializers.ValidationError("You don't have access to this relationship")
        
        return value


class ConnectedUserDetailsSerializer(serializers.Serializer):
    """Serializer for connected user details with transactions"""
    # User info
    user_id = serializers.IntegerField()
    email = serializers.EmailField()
    phone_number = serializers.CharField(allow_null=True)
    full_name = serializers.CharField()
    profile_picture = serializers.CharField(allow_null=True)
    
    # Business specific (if user is business)
    is_business = serializers.BooleanField()
    business_id = serializers.IntegerField(allow_null=True)
    business_name = serializers.CharField(allow_null=True)
    
    # Customer specific (if user is customer)
    customer_id = serializers.IntegerField(allow_null=True)
    
    # Relationship info
    relationship_id = serializers.IntegerField()
    connected_at = serializers.DateTimeField()
    
    # Financial summary
    to_pay = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_paid = serializers.DecimalField(max_digits=12, decimal_places=2)
    
    # For customers viewing businesses
    is_favorite = serializers.BooleanField(default=False)
    
    # Transactions
    transactions = TransactionSerializer(many=True)


class FavoriteSerializer(serializers.ModelSerializer):
    """Serializer for favorite businesses"""
    business_id = serializers.IntegerField(source='business.business_id', read_only=True)
    business_name = serializers.CharField(source='business.business_name', read_only=True)
    business_profile_picture = serializers.SerializerMethodField()
    
    class Meta:
        model = Favorite
        fields = [
            'favorite_id',
            'business_id',
            'business_name',
            'business_profile_picture',
            'created_at',
        ]
        read_only_fields = ['favorite_id', 'created_at']
    
    def get_business_profile_picture(self, obj):
        if obj.business.user.profile_picture:
            return obj.business.user.profile_picture.url
        return None


class AddFavoriteSerializer(serializers.Serializer):
    """Serializer for adding a business to favorites"""
    business_id = serializers.IntegerField()
    
    def validate_business_id(self, value):
        """Validate that business exists"""
        from business_dashboard.models import Business
        try:
            Business.objects.get(business_id=value)
        except Business.DoesNotExist:
            raise serializers.ValidationError("Business not found")
        return value
