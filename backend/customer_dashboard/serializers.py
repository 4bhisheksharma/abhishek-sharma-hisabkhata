from rest_framework import serializers
from .models import Customer
from hisabauth.models import User


class CustomerSerializer(serializers.ModelSerializer):
    """Serializer for Customer profile"""
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    phone_number = serializers.CharField(source='user.phone_number', read_only=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', read_only=True)
    
    class Meta:
        model = Customer
        fields = [
            'customer_id', 'email', 'full_name', 'phone_number',
            'profile_picture', 'status',
            'created_at', 'updated_at'
        ]
