from rest_framework import serializers
from .models import Customer
from hisabauth.models import User


class CustomerDashboardSerializer(serializers.ModelSerializer):
    """Serializer for Customer Dashboard - returns flattened structure"""
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', read_only=True)
    to_give = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    to_take = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    total_shops = serializers.IntegerField(read_only=True)
    pending_requests = serializers.IntegerField(read_only=True)
    recent_transactions = serializers.ListField(read_only=True)
    loyalty_points = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Customer
        fields = [
            'customer_id', 'full_name', 'profile_picture',
            'to_give', 'to_take', 'total_shops', 'pending_requests',
            'recent_transactions', 'loyalty_points'
        ]


class CustomerProfileSerializer(serializers.ModelSerializer):
    """Serializer for Customer Profile"""
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', required=False)
    phone_number = serializers.CharField(source='user.phone_number', required=False, allow_null=True, allow_blank=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', required=False, allow_null=True)
    
    class Meta:
        model = Customer
        fields = [
            'full_name', 'phone_number', 'profile_picture', 'email'
        ]
    
    def update(self, instance, validated_data):
        """Update customer profile - updates User model fields"""
        user_data = validated_data.pop('user', {})
        
        # Update User fields
        if user_data:
            user = instance.user
            if 'full_name' in user_data:
                user.full_name = user_data['full_name']
            if 'phone_number' in user_data:
                user.phone_number = user_data['phone_number']
            if 'profile_picture' in user_data:
                user.profile_picture = user_data['profile_picture']
            user.save()
        
        # Update Customer fields if any
        instance.save()
        return instance
