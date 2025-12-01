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
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    phone_number = serializers.CharField(source='user.phone_number', read_only=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', read_only=True)
    
    class Meta:
        model = Customer
        fields = [
            'full_name', 'phone_number', 'profile_picture', 'email'
        ]
