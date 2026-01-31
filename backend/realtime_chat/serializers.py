from rest_framework import serializers
from .models import ChatRoom, Message, MessageStatus
from customer_dashboard.models import CustomerBusinessRelationship
from hisabauth.models import User


class UserBasicSerializer(serializers.ModelSerializer):
    """Lightweight user serializer for chat context"""
    class Meta:
        model = User
        fields = ['user_id', 'full_name', 'email', 'phone_number', 'profile_picture']
        read_only_fields = fields


class MessageStatusSerializer(serializers.ModelSerializer):
    """Serializer for message read/delivery status"""
    user = UserBasicSerializer(read_only=True)
    
    class Meta:
        model = MessageStatus
        fields = ['message_status_id', 'message', 'user', 'status', 'timestamp']
        read_only_fields = ['message_status_id', 'timestamp']


class MessageSerializer(serializers.ModelSerializer):
    """Serializer for displaying messages"""
    sender = UserBasicSerializer(read_only=True)
    statuses = MessageStatusSerializer(many=True, read_only=True)
    is_mine = serializers.SerializerMethodField()
    
    class Meta:
        model = Message
        fields = [
            'message_id', 'chat_room', 'sender', 'message_type', 
            'content', 'file_url', 'is_edited', 'is_deleted',
            'created_at', 'updated_at', 'statuses', 'is_mine'
        ]
        read_only_fields = ['message_id', 'created_at', 'updated_at', 'is_edited']
    
    def get_is_mine(self, obj):
        """Check if the message belongs to the current user"""
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            return obj.sender == request.user
        return False


class MessageCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating new messages"""
    class Meta:
        model = Message
        fields = ['chat_room', 'message_type', 'content', 'file_url']
    
    def validate_chat_room(self, value):
        """Ensure user has access to this chat room"""
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            raise serializers.ValidationError("Authentication required")
        
        user = request.user
        relationship = value.relationship
        
        # Check if user is either the customer or the business owner
        is_customer = (
            hasattr(user, 'customer_profile') and 
            relationship.customer == user.customer_profile
        )
        is_business = (
            hasattr(user, 'business_profile') and 
            relationship.business == user.business_profile
        )
        
        if not (is_customer or is_business):
            raise serializers.ValidationError(
                "You don't have permission to send messages in this chat room"
            )
        
        return value
    
    def create(self, validated_data):
        """Auto-assign sender from request user"""
        validated_data['sender'] = self.context['request'].user
        return super().create(validated_data)


class MessageUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating messages"""
    class Meta:
        model = Message
        fields = ['content', 'file_url']
    
    def update(self, instance, validated_data):
        """Mark message as edited when content changes"""
        if 'content' in validated_data and validated_data['content'] != instance.content:
            instance.is_edited = True
        instance = super().update(instance, validated_data)
        return instance


class RelationshipBasicSerializer(serializers.ModelSerializer):
    """Basic relationship info for chat room context"""
    customer_name = serializers.CharField(source='customer.user.full_name', read_only=True)
    business_name = serializers.CharField(source='business.business_name', read_only=True)
    customer_id = serializers.IntegerField(source='customer.customer_id', read_only=True)
    business_id = serializers.IntegerField(source='business.business_id', read_only=True)
    customer_user_id = serializers.IntegerField(source='customer.user.user_id', read_only=True)
    business_user_id = serializers.IntegerField(source='business.user.user_id', read_only=True)
    
    class Meta:
        model = CustomerBusinessRelationship
        fields = [
            'relationship_id', 'customer_id', 'business_id',
            'customer_user_id', 'business_user_id',
            'customer_name', 'business_name', 'status'
        ]


class ChatRoomSerializer(serializers.ModelSerializer):
    """Serializer for chat rooms with relationship details"""
    relationship = RelationshipBasicSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    other_user = serializers.SerializerMethodField()
    
    class Meta:
        model = ChatRoom
        fields = [
            'chat_room_id', 'relationship', 'created_at', 
            'updated_at', 'last_message', 'unread_count', 'other_user'
        ]
        read_only_fields = fields
    
    def get_last_message(self, obj):
        """Get the most recent message in this chat room"""
        last_message = obj.messages.filter(is_deleted=False).order_by('-created_at').first()
        if last_message:
            return MessageSerializer(last_message, context=self.context).data
        return None
    
    def get_unread_count(self, obj):
        """Count unread messages for the current user"""
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            return 0
        
        user = request.user
        # Count messages not sent by user and not marked as read
        unread = Message.objects.filter(
            chat_room=obj,
            is_deleted=False
        ).exclude(
            sender=user
        ).exclude(
            statuses__user=user,
            statuses__status='read'
        ).count()
        
        return unread
    
    def get_other_user(self, obj):
        """Get the other user in this conversation"""
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            return None
        
        user = request.user
        relationship = obj.relationship
        
        # Determine if current user is customer or business
        if hasattr(user, 'customer_profile') and relationship.customer == user.customer_profile:
            # Current user is customer, return business user
            other_user = relationship.business.user
        elif hasattr(user, 'business_profile') and relationship.business == user.business_profile:
            # Current user is business, return customer user
            other_user = relationship.customer.user
        else:
            return None
        
        return UserBasicSerializer(other_user).data


class ChatRoomDetailSerializer(ChatRoomSerializer):
    """Detailed chat room serializer with paginated messages"""
    messages = serializers.SerializerMethodField()
    
    class Meta(ChatRoomSerializer.Meta):
        fields = ChatRoomSerializer.Meta.fields + ['messages']
    
    def get_messages(self, obj):
        """Get messages with pagination info from context"""
        # The view will handle pagination, so we just return the queryset info
        messages = obj.messages.filter(is_deleted=False).order_by('created_at')
        return MessageSerializer(messages, many=True, context=self.context).data
