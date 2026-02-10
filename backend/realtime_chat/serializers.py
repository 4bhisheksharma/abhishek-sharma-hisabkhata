from rest_framework import serializers
from .models import ChatRoom, Message
from hisabauth.models import User


class UserBasicSerializer(serializers.ModelSerializer):
    """Basic user info for chat context."""
    is_business = serializers.SerializerMethodField()
    business_name = serializers.SerializerMethodField()
    display_name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['user_id', 'full_name', 'email', 'profile_picture', 'is_business', 'business_name', 'display_name']
    
    def get_is_business(self, obj):
        """Check if user has a business profile."""
        return hasattr(obj, 'business_profile') and obj.business_profile is not None
    
    def get_business_name(self, obj):
        """Get business name if user is a business."""
        if hasattr(obj, 'business_profile') and obj.business_profile:
            return obj.business_profile.business_name
        return None
    
    def get_display_name(self, obj):
        """Get display name (business name for businesses, full name for others)."""
        if hasattr(obj, 'business_profile') and obj.business_profile:
            return obj.business_profile.business_name
        return obj.full_name


class MessageSerializer(serializers.ModelSerializer):
    """Serializer for chat messages."""
    sender = UserBasicSerializer(read_only=True)
    sender_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Message
        fields = [
            'message_id',
            'chat_room',
            'sender',
            'sender_id',
            'content',
            'message_type',
            'is_read',
            'read_at',
            'created_at',
        ]
        read_only_fields = ['message_id', 'is_read', 'read_at', 'created_at']


class MessageCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating messages via REST API."""
    
    class Meta:
        model = Message
        fields = ['chat_room', 'content', 'message_type']
        
    def create(self, validated_data):
        validated_data['sender'] = self.context['request'].user
        return super().create(validated_data)


class ChatRoomSerializer(serializers.ModelSerializer):
    """Serializer for chat rooms with participant details."""
    participant_one = UserBasicSerializer(read_only=True)
    participant_two = UserBasicSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    other_participant = serializers.SerializerMethodField()
    
    class Meta:
        model = ChatRoom
        fields = [
            'chat_room_id',
            'participant_one',
            'participant_two',
            'other_participant',
            'last_message',
            'unread_count',
            'last_message_at',
            'created_at',
        ]
    
    def get_last_message(self, obj):
        """Get the most recent message in the chat room."""
        last_msg = obj.messages.order_by('-created_at').first()
        if last_msg:
            return {
                'content': last_msg.content,
                'sender_id': last_msg.sender.user_id,
                'sender_name': last_msg.sender.full_name,
                'created_at': last_msg.created_at.isoformat(),
                'is_read': last_msg.is_read,
            }
        return None
    
    def get_unread_count(self, obj):
        """Get unread message count for current user."""
        request = self.context.get('request')
        if request and request.user:
            return obj.get_unread_count(request.user)
        return 0
    
    def get_other_participant(self, obj):
        """Get the other participant's info for the current user."""
        request = self.context.get('request')
        if request and request.user:
            other = obj.get_other_participant(request.user)
            return UserBasicSerializer(other).data
        return None


class ChatRoomCreateSerializer(serializers.Serializer):
    """Serializer for creating/getting a chat room with another user."""
    other_user_id = serializers.IntegerField()
    
    def validate_other_user_id(self, value):
        """Validate that the other user exists and is connected."""
        try:
            User.objects.get(user_id=value)
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found.")
        return value
    
    def create(self, validated_data):
        current_user = self.context['request'].user
        other_user = User.objects.get(user_id=validated_data['other_user_id'])
        
        # Check if users are connected (have an active relationship)
        # This can be expanded based on your connection logic
        room, created = ChatRoom.get_or_create_room(current_user, other_user)
        return room
