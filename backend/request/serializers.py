from rest_framework import serializers
from .models import BusinessCustomerRequest
from hisabauth.models import User


class UserSearchSerializer(serializers.ModelSerializer):
    """Serializer for user search results"""
    
    class Meta:
        model = User
        fields = ['user_id', 'email', 'phone_number', 'full_name', 'profile_picture']
        read_only_fields = ['user_id', 'email', 'phone_number', 'full_name', 'profile_picture']


class ConnectionRequestSerializer(serializers.ModelSerializer):
    """Serializer for connection requests"""
    sender_email = serializers.EmailField(source='sender.email', read_only=True)
    sender_name = serializers.CharField(source='sender.full_name', read_only=True)
    sender_phone = serializers.CharField(source='sender.phone_number', read_only=True)
    receiver_email = serializers.EmailField(source='receiver.email', read_only=True)
    receiver_name = serializers.CharField(source='receiver.full_name', read_only=True)
    receiver_phone = serializers.CharField(source='receiver.phone_number', read_only=True)
    
    class Meta:
        model = BusinessCustomerRequest
        fields = [
            'business_customer_request_id',
            'sender',
            'sender_email',
            'sender_name',
            'sender_phone',
            'receiver',
            'receiver_email',
            'receiver_name',
            'receiver_phone',
            'status',
            'created_at',
            'updated_at'
        ]
        read_only_fields = [
            'business_customer_request_id',
            'sender',
            'sender_email',
            'sender_name',
            'sender_phone',
            'receiver_email',
            'receiver_name',
            'receiver_phone',
            'created_at',
            'updated_at'
        ]


class SendRequestSerializer(serializers.Serializer):
    """Serializer for sending connection request"""
    receiver_id = serializers.IntegerField(required=True)
    
    def validate_receiver_id(self, value):
        """Validate that receiver exists and is not the sender"""
        request = self.context.get('request')
        if not request or not request.user:
            raise serializers.ValidationError("Authentication required")
        
        if value == request.user.user_id:
            raise serializers.ValidationError("You cannot send a request to yourself")
        
        try:
            User.objects.get(user_id=value)
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found")
        
        return value


class UpdateRequestStatusSerializer(serializers.Serializer):
    """Serializer for updating request status"""
    status = serializers.ChoiceField(choices=['accepted', 'rejected'])
