from rest_framework import serializers
from .models import BusinessCustomerRequest
from hisabauth.models import User


class UserSearchSerializer(serializers.ModelSerializer):
    """Serializer for user search results"""
    
    class Meta:
        model = User
        fields = ['user_id', 'email', 'phone_number', 'full_name', 'profile_picture']
        read_only_fields = ['user_id', 'email', 'phone_number', 'full_name', 'profile_picture']


class ConnectedUserSerializer(serializers.ModelSerializer):
    """Serializer for connected users with business details"""
    is_business = serializers.SerializerMethodField()
    business_id = serializers.SerializerMethodField()
    business_name = serializers.SerializerMethodField()
    customer_id = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'user_id', 
            'email', 
            'phone_number', 
            'full_name', 
            'profile_picture',
            'is_business',
            'business_id',
            'business_name',
            'customer_id',
        ]
        read_only_fields = fields
    
    def get_is_business(self, obj):
        return hasattr(obj, 'business_profile')
    
    def get_business_id(self, obj):
        if hasattr(obj, 'business_profile'):
            return obj.business_profile.business_id
        return None
    
    def get_business_name(self, obj):
        if hasattr(obj, 'business_profile'):
            return obj.business_profile.business_name
        return None
    
    def get_customer_id(self, obj):
        if hasattr(obj, 'customer_profile'):
            return obj.customer_profile.customer_id
        return None


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
    """Serializer for sending connection request - accepts email or user_id"""
    receiver_email = serializers.EmailField(required=False)
    receiver_id = serializers.IntegerField(required=False)
    
    def validate(self, data):
        """Validate that either receiver_email or receiver_id is provided"""
        if not data.get('receiver_email') and not data.get('receiver_id'):
            raise serializers.ValidationError(
                "Either 'receiver_email' or 'receiver_id' must be provided"
            )
        
        if data.get('receiver_email') and data.get('receiver_id'):
            raise serializers.ValidationError(
                "Provide only one: 'receiver_email' or 'receiver_id'"
            )
        
        request = self.context.get('request')
        if not request or not request.user:
            raise serializers.ValidationError("Authentication required")
        
        # Find the receiver user
        try:
            if data.get('receiver_email'):
                receiver = User.objects.get(email=data['receiver_email'])
            else:
                receiver = User.objects.get(user_id=data['receiver_id'])
            
            # Check if trying to send to self
            if receiver.user_id == request.user.user_id:
                raise serializers.ValidationError("You cannot send a request to yourself")
            
            # Store the receiver in validated data for the view to use
            data['receiver'] = receiver
            
        except User.DoesNotExist:
            field = 'email' if data.get('receiver_email') else 'user_id'
            raise serializers.ValidationError(f"User with this {field} not found")
        
        return data


class UpdateRequestStatusSerializer(serializers.Serializer):
    """Serializer for updating request status"""
    status = serializers.ChoiceField(choices=['accepted', 'rejected'])
