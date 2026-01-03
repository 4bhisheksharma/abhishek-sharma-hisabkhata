from rest_framework import serializers
from .models import Customer
from hisabauth.models import User


class CustomerDashboardSerializer(serializers.ModelSerializer):
    """Serializer for Customer Dashboard - returns flattened structure"""
    full_name = serializers.CharField(source='user.full_name', read_only=True)
    profile_picture = serializers.SerializerMethodField()
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
    
    def get_profile_picture(self, obj):
        """Return profile picture URL with /media/ prefix"""
        if obj.user.profile_picture:
            return f"/media/{obj.user.profile_picture}"
        return None


class CustomerProfileSerializer(serializers.ModelSerializer):
    """Serializer for Customer Profile"""
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', required=False)
    phone_number = serializers.CharField(source='user.phone_number', required=False, allow_null=True, allow_blank=True)
    profile_picture = serializers.ImageField(source='user.profile_picture', required=False, allow_null=True, write_only=True)
    profile_picture_url = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = Customer
        fields = [
            'full_name', 'phone_number', 'profile_picture', 'profile_picture_url', 'email'
        ]
    
    def get_profile_picture_url(self, obj):
        """Return profile picture URL with /media/ prefix"""
        if obj.user.profile_picture:
            return f"/media/{obj.user.profile_picture}"
        return None
    
    def to_representation(self, instance):
        """Override to return profile_picture_url as profile_picture"""
        data = super().to_representation(instance)
        # Remove write-only field from response and rename url field
        data.pop('profile_picture', None)
        data['profile_picture'] = data.pop('profile_picture_url', None)
        return data
    
    def update(self, instance, validated_data):
        """Update customer profile - updates User model fields"""
        import os
        user_data = validated_data.pop('user', {})
        
        # Update User fields
        if user_data:
            user = instance.user
            if 'full_name' in user_data:
                user.full_name = user_data['full_name']
            if 'phone_number' in user_data:
                user.phone_number = user_data['phone_number']
            if 'profile_picture' in user_data:
                # Delete old profile picture if it exists
                if user.profile_picture:
                    old_picture_path = user.profile_picture.path
                    if os.path.exists(old_picture_path):
                        os.remove(old_picture_path)
                
                # Set new profile picture
                user.profile_picture = user_data['profile_picture']
            user.save()
        
        # Update Customer fields if any
        instance.save()
        return instance


class RecentBusinessSerializer(serializers.Serializer):
    """Serializer for recently added businesses for a customer"""
    business_id = serializers.IntegerField(source='business.business_id')
    name = serializers.CharField(source='business.business_name')
    profile_picture = serializers.SerializerMethodField()
    contact = serializers.SerializerMethodField()
    email = serializers.EmailField(source='business.user.email')
    pending_due = serializers.DecimalField(max_digits=12, decimal_places=2)
    added_at = serializers.DateTimeField(source='created_at')
    
    def get_profile_picture(self, obj):
        """Return profile picture URL with /media/ prefix"""
        if obj.business.user.profile_picture:
            return f"/media/{obj.business.user.profile_picture}"
        return None
    
    def get_contact(self, obj):
        """Return phone number if available"""
        return obj.business.user.phone_number or None
