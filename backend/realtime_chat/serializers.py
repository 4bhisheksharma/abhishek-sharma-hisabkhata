from rest_framework import serializers
from .models import ChatRoom, Message, MessageStatus
from hisabauth.models import User


class MessageStatusSerializer(serializers.ModelSerializer):
    """Serializer for message status"""
    user_name = serializers.CharField(source='user.full_name', read_only=True)
    user_email = serializers.EmailField(source='user.email', read_only=True)
    
    class Meta:
        model = MessageStatus
        fields = [
            'message_status_id',
            'user',
            'user_name',
            'user_email',
            'status',
            'timestamp'
        ]
        read_only_fields = ['message_status_id', 'timestamp']


class MessageSerializer(serializers.ModelSerializer):
    """Serializer for message details"""
    sender_name = serializers.CharField(source='sender.full_name', read_only=True)
    sender_email = serializers.EmailField(source='sender.email', read_only=True)
    sender_profile_picture = serializers.ImageField(source='sender.profile_picture', read_only=True)
    statuses = MessageStatusSerializer(many=True, read_only=True)
    
    class Meta:
        model = Message
        fields = [
            'message_id',
            'chat_room',
            'sender',
            'sender_name',
            'sender_email',
            'sender_profile_picture',
            'message_type',
            'content',
            'file_url',
            'is_edited',
            'is_deleted',
            'statuses',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['message_id', 'sender', 'created_at', 'updated_at']


class ChatRoomSerializer(serializers.ModelSerializer):
    """Serializer for chat room details"""
    customer_name = serializers.CharField(source='relationship.customer.user.full_name', read_only=True)
    customer_email = serializers.EmailField(source='relationship.customer.user.email', read_only=True)
    customer_profile_picture = serializers.ImageField(source='relationship.customer.user.profile_picture', read_only=True)
    business_name = serializers.CharField(source='relationship.business.business_name', read_only=True)
    business_email = serializers.EmailField(source='relationship.business.user.email', read_only=True)
    business_profile_picture = serializers.ImageField(source='relationship.business.user.profile_picture', read_only=True)
    relationship_id = serializers.IntegerField(source='relationship.relationship_id', read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    
    class Meta:
        model = ChatRoom
        fields = [
            'chat_room_id',
            'relationship_id',
            'customer_name',
            'customer_email',
            'customer_profile_picture',
            'business_name',
            'business_email',
            'business_profile_picture',
            'last_message',
            'unread_count',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['chat_room_id', 'created_at', 'updated_at']
    
    def get_last_message(self, obj):
        """Get the last message in the chat room"""
        last_msg = obj.messages.filter(is_deleted=False).order_by('-created_at').first()
        if last_msg:
            return {
                'message_id': last_msg.message_id,
                'content': last_msg.content,
                'message_type': last_msg.message_type,
                'sender_name': last_msg.sender.full_name,
                'created_at': last_msg.created_at
            }
        return None
    
    def get_unread_count(self, obj):
        """Get unread message count for current user"""
        request = self.context.get('request')
        if request and request.user:
            # Count messages where status is not 'read' for current user
            return MessageStatus.objects.filter(
                message__chat_room=obj,
                user=request.user,
                status__in=['sent', 'delivered']
            ).count()
        return 0


class SendMessageSerializer(serializers.Serializer):
    """Serializer for sending a new message"""
    chat_room_id = serializers.IntegerField()
    message_type = serializers.ChoiceField(
        choices=['text', 'image', 'file', 'transaction_update', 'system'],
        default='text'
    )
    content = serializers.CharField()
    file_url = serializers.URLField(required=False, allow_blank=True)
    
    def validate_chat_room_id(self, value):
        """Validate that chat room exists and user has access"""
        request = self.context.get('request')
        user = request.user
        
        try:
            chat_room = ChatRoom.objects.select_related(
                'relationship__customer__user',
                'relationship__business__user'
            ).get(chat_room_id=value)
        except ChatRoom.DoesNotExist:
            raise serializers.ValidationError("Chat room not found")
        
        # Check if user is part of this chat room
        is_customer = hasattr(user, 'customer_profile') and chat_room.relationship.customer == user.customer_profile
        is_business = hasattr(user, 'business_profile') and chat_room.relationship.business == user.business_profile
        
        if not is_customer and not is_business:
            raise serializers.ValidationError("You don't have access to this chat room")
        
        return value
