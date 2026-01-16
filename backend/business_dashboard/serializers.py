from rest_framework import serializers
from .models import Business
from hisabauth.models import User


class BusinessDashboardSerializer(serializers.ModelSerializer):
    """Serializer for Business Dashboard - returns flattened structure"""
    business_name = serializers.CharField(read_only=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', read_only=True)
    to_give = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    to_take = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    total_customers = serializers.IntegerField(read_only=True)
    total_requests = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Business
        fields = [
            'business_id', 'business_name', 'profile_picture',
            'to_give', 'to_take', 'total_customers', 'total_requests'
        ]


class BusinessProfileSerializer(serializers.ModelSerializer):
    """Serializer for Business Profile"""
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', required=False)
    phone_number = serializers.CharField(source='user.phone_number', required=False, allow_null=True, allow_blank=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', required=False, allow_null=True)
    business_name = serializers.CharField(required=False)
    is_verified = serializers.BooleanField(read_only=True)
    preferred_language = serializers.CharField(source='user.preferred_language', required=False)
    
    class Meta:
        model = Business
        fields = [
            'business_name', 'full_name', 'phone_number', 
            'profile_picture', 'email', 'is_verified', 'preferred_language'
        ]
    
    def update(self, instance, validated_data):
        """Update business profile - updates both Business and User model fields"""
        import os
        user_data = validated_data.pop('user', {})
        
        # Update Business fields
        if 'business_name' in validated_data:
            instance.business_name = validated_data['business_name']
        
        # Update User fields
        if user_data:
            user = instance.user
            if 'full_name' in user_data:
                user.full_name = user_data['full_name']
            if 'phone_number' in user_data:
                # Convert empty string to None to avoid UNIQUE constraint violation
                phone = user_data['phone_number']
                user.phone_number = phone if phone and phone.strip() else None
            if 'preferred_language' in user_data:
                user.preferred_language = user_data['preferred_language']
            
            # Handle profile picture update
            if 'profile_picture' in user_data:
                # Delete old profile picture if it exists
                if user.profile_picture:
                    old_picture_path = user.profile_picture.path
                    if os.path.exists(old_picture_path):
                        os.remove(old_picture_path)
                
                user.profile_picture = user_data['profile_picture']
            
            user.save()
        
        instance.save()
        return instance


class RecentCustomerSerializer(serializers.Serializer):
    """Serializer for recently added customers for a business"""
    relationship_id = serializers.IntegerField()
    customer_id = serializers.IntegerField(source='customer.customer_id')
    name = serializers.CharField(source='customer.user.full_name')
    profile_picture = serializers.SerializerMethodField()
    contact = serializers.SerializerMethodField()
    email = serializers.EmailField(source='customer.user.email')
    pending_due = serializers.DecimalField(max_digits=12, decimal_places=2)
    added_at = serializers.DateTimeField(source='created_at')
    
    def get_profile_picture(self, obj):
        """Return profile picture URL with /media/ prefix"""
        if obj.customer.user.profile_picture:
            return f"/media/{obj.customer.user.profile_picture}"
        return None
    
    def get_contact(self, obj):
        """Return phone number if available"""
        return obj.customer.user.phone_number or None
