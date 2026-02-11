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
    sender_profile_picture = serializers.ImageField(source='sender.profile_picture', read_only=True)
    receiver_email = serializers.EmailField(source='receiver.email', read_only=True)
    receiver_name = serializers.CharField(source='receiver.full_name', read_only=True)
    receiver_phone = serializers.CharField(source='receiver.phone_number', read_only=True)
    receiver_profile_picture = serializers.ImageField(source='receiver.profile_picture', read_only=True)
    
    class Meta:
        model = BusinessCustomerRequest
        fields = [
            'business_customer_request_id',
            'sender',
            'sender_email',
            'sender_name',
            'sender_phone',
            'sender_profile_picture',
            'receiver',
            'receiver_email',
            'receiver_name',
            'receiver_phone',
            'receiver_profile_picture',
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
            'sender_profile_picture',
            'receiver_email',
            'receiver_name',
            'receiver_phone',
            'receiver_profile_picture',
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


class BulkSendRequestSerializer(serializers.Serializer):
    """Serializer for sending bulk connection requests"""
    receivers = serializers.ListField(
        child=serializers.DictField(),
        min_length=1,
        max_length=100,  # Limit bulk requests to 100 users
        help_text="List of receivers with 'email' or 'user_id'"
    )
    
    def validate_receivers(self, receivers):
        """Validate each receiver in the list"""
        if not receivers:
            raise serializers.ValidationError("Receivers list cannot be empty")
        
        validated_receivers = []
        errors = []
        
        for idx, receiver_data in enumerate(receivers):
            # Check that each item has either email or user_id
            if not receiver_data.get('email') and not receiver_data.get('user_id'):
                errors.append({
                    'index': idx,
                    'error': "Each receiver must have either 'email' or 'user_id'"
                })
                continue
            
            if receiver_data.get('email') and receiver_data.get('user_id'):
                errors.append({
                    'index': idx,
                    'error': "Provide only one: 'email' or 'user_id'"
                })
                continue
            
            # Find the receiver user
            try:
                if receiver_data.get('email'):
                    user = User.objects.get(email=receiver_data['email'])
                else:
                    user = User.objects.get(user_id=receiver_data['user_id'])
                
                validated_receivers.append(user)
            except User.DoesNotExist:
                field = 'email' if receiver_data.get('email') else 'user_id'
                value = receiver_data.get('email') or receiver_data.get('user_id')
                errors.append({
                    'index': idx,
                    'error': f"User with {field} '{value}' not found"
                })
        
        if errors:
            raise serializers.ValidationError({
                'receivers': errors,
                'message': f'{len(errors)} receiver(s) had validation errors'
            })
        
        return validated_receivers
    
    def validate(self, data):
        """Additional validation after receivers are validated"""
        request = self.context.get('request')
        if not request or not request.user:
            raise serializers.ValidationError("Authentication required")
        
        receivers = data.get('receivers', [])
        
        # Remove self from receivers if present
        receivers = [r for r in receivers if r.user_id != request.user.user_id]
        
        # Remove duplicates (by user_id)
        seen_ids = set()
        unique_receivers = []
        for receiver in receivers:
            if receiver.user_id not in seen_ids:
                seen_ids.add(receiver.user_id)
                unique_receivers.append(receiver)
        
        data['receivers'] = unique_receivers
        return data


class BulkRequestResultSerializer(serializers.Serializer):
    """Serializer for bulk request operation results"""
    total_requested = serializers.IntegerField()
    successful = serializers.IntegerField()
    failed = serializers.IntegerField()
    skipped = serializers.IntegerField()
    results = serializers.ListField()
    summary = serializers.DictField()


class BulkUpdateStatusSerializer(serializers.Serializer):
    """Serializer for bulk updating request status"""
    request_ids = serializers.ListField(
        child=serializers.IntegerField(),
        min_length=1,
        max_length=100,
        help_text="List of request IDs to update"
    )
    status = serializers.ChoiceField(
        choices=['accepted', 'rejected'],
        help_text="Status to apply to all requests"
    )
