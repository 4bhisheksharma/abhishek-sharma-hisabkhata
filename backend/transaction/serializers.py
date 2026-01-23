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
        choices=['purchase', 'payment', 'credit', 'refund', 'adjustment'],
        default='purchase',
        required=False
    )
    description = serializers.CharField(max_length=255, required=False, allow_blank=True)
    item_title = serializers.CharField(max_length=100, required=False, allow_blank=True)
    transaction_date = serializers.DateTimeField(required=False)
    
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
    
    def validate(self, data):
        """Validate transaction type based on user role"""
        request = self.context.get('request')
        user = request.user
        relationship = CustomerBusinessRelationship.objects.get(relationship_id=data['relationship_id'])
        
        is_customer = hasattr(user, 'customer_profile') and relationship.customer == user.customer_profile
        is_business = hasattr(user, 'business_profile') and relationship.business == user.business_profile
        
        transaction_type = data.get('transaction_type', 'purchase')
        
        # Customers can only create payment transactions
        if is_customer and transaction_type != 'payment':
            raise serializers.ValidationError({
                'transaction_type': 'Customers can only create payment transactions'
            })
        
        # Businesses cannot create payment transactions (customers pay)
        if is_business and transaction_type == 'payment':
            raise serializers.ValidationError({
                'transaction_type': 'Businesses cannot create payment transactions. Customers make payments.'
            })
        
        # Combine item_title and description
        item_title = data.get('item_title', '')
        description = data.get('description', '')
        if item_title and description:
            data['description'] = f"{item_title}: {description}"
        elif item_title:
            data['description'] = item_title
        
        return data


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
    """Serializer for favorites - handles both customer favorites and business favorites"""
    
    # For customers viewing favorite businesses
    business_id = serializers.SerializerMethodField()
    business_name = serializers.SerializerMethodField()
    business_profile_picture = serializers.SerializerMethodField()
    
    # For businesses viewing customers who favorited them
    customer_id = serializers.SerializerMethodField()
    customer_name = serializers.SerializerMethodField()
    customer_profile_picture = serializers.SerializerMethodField()
    
    class Meta:
        model = Favorite
        fields = [
            'favorite_id',
            'business_id',
            'business_name',
            'business_profile_picture',
            'customer_id',
            'customer_name',
            'customer_profile_picture',
            'created_at',
        ]
        read_only_fields = ['favorite_id', 'created_at']
    
    def get_business_id(self, obj):
        return obj.business.business_id if obj.business else None
    
    def get_business_name(self, obj):
        return obj.business.business_name if obj.business else None
    
    def get_business_profile_picture(self, obj):
        if obj.business and obj.business.user.profile_picture:
            return obj.business.user.profile_picture.url
        return None
    
    def get_customer_id(self, obj):
        return obj.customer.customer_id if obj.customer else None
    
    def get_customer_name(self, obj):
        return obj.customer.user.full_name if obj.customer else None
    
    def get_customer_profile_picture(self, obj):
        if obj.customer and obj.customer.user.profile_picture:
            return obj.customer.user.profile_picture.url
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
