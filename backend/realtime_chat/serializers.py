from rest_framework import serializers
from .models import ChatRoom, Message, MessageStatus
from customer_dashboard.models import CustomerBusinessRelationship
from hisabauth.models import User


class UserBasicSerializer(serializers.ModelSerializer):
    """Minimal user serializer for chat context"""
    class Meta:
        model = User
        fields = ['user_id', 'full_name', 'email', 'profile_picture']
        read_only_fields = fields


class MessageStatusBasicSerializer(serializers.ModelSerializer):
    """Basic message status serializer"""
    class Meta:
        model = MessageStatus
        fields = ['status', 'timestamp']


class MessageListSerializer(serializers.ModelSerializer):
    """Optimized serializer for message lists"""
    sender = UserBasicSerializer(read_only=True)
    statuses = MessageStatusBasicSerializer(many=True, read_only=True)
    is_mine = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'message_id', 'sender', 'message_type',
            'content', 'file_url', 'is_edited', 'is_deleted',
            'created_at', 'statuses', 'is_mine'
        ]
        read_only_fields = fields

    def get_is_mine(self, obj):
        """Check if the message belongs to the current user"""
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            return obj.sender == request.user
        return False


class MessageDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for single message view"""
    sender = UserBasicSerializer(read_only=True)
    statuses = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'message_id', 'chat_room', 'sender', 'message_type',
            'content', 'file_url', 'is_edited', 'is_deleted',
            'created_at', 'updated_at', 'statuses'
        ]
        read_only_fields = fields

    def get_statuses(self, obj):
        """Get message statuses with user info"""
        return MessageStatusSerializer(obj.statuses.all(), many=True, context=self.context).data


class RelationshipBasicSerializer(serializers.ModelSerializer):
    """Basic relationship info for chat room context"""
    customer_name = serializers.CharField(source='customer.user.full_name', read_only=True)
    business_name = serializers.CharField(source='business.business_name', read_only=True)

    class Meta:
        model = CustomerBusinessRelationship
        fields = ['relationship_id', 'customer_name', 'business_name', 'status']


class ChatRoomListSerializer(serializers.ModelSerializer):
    """Optimized serializer for chat room lists"""
    relationship = RelationshipBasicSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    other_user = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = [
            'chat_room_id', 'relationship', 'created_at',
            'last_message', 'unread_count', 'other_user'
        ]
        read_only_fields = fields

    def get_last_message(self, obj):
        """Get basic info of the most recent message"""
        last_message = obj.messages.filter(is_deleted=False).order_by('-created_at').first()
        if last_message:
            return {
                'message_id': last_message.message_id,
                'content': last_message.content[:50] + '...' if len(last_message.content) > 50 else last_message.content,
                'sender_name': last_message.sender.full_name,
                'created_at': last_message.created_at,
                'message_type': last_message.message_type
            }
        return None

    def get_unread_count(self, obj):
        """Count unread messages for the current user"""
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            return 0

        user = request.user
        return Message.objects.filter(
            chat_room=obj,
            is_deleted=False
        ).exclude(
            sender=user
        ).exclude(
            statuses__user=user,
            statuses__status='read'
        ).count()

    def get_other_user(self, obj):
        """Get basic info of the other user in this conversation"""
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            return None

        user = request.user
        relationship = obj.relationship

        if hasattr(user, 'customer_profile') and relationship.customer == user.customer_profile:
            other_user = relationship.business.user
        elif hasattr(user, 'business_profile') and relationship.business == user.business_profile:
            other_user = relationship.customer.user
        else:
            return None

        return {
            'user_id': other_user.user_id,
            'full_name': other_user.full_name,
            'email': other_user.email,
            'profile_picture': other_user.profile_picture.url if other_user.profile_picture else None
        }


class ChatRoomDetailSerializer(ChatRoomListSerializer):
    """Detailed chat room serializer with full messages"""
    messages = serializers.SerializerMethodField()

    class Meta(ChatRoomListSerializer.Meta):
        fields = ChatRoomListSerializer.Meta.fields + ['messages']

    def get_messages(self, obj):
        """Get messages with pagination info from context"""
        messages = obj.messages.filter(is_deleted=False).order_by('created_at')
        return MessageListSerializer(messages, many=True, context=self.context).data


# Keep the original detailed serializers for create/update operations
class MessageCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating new messages"""
    class Meta:
        model = Message
        fields = ['chat_room', 'message_type', 'content', 'file_url']

    def validate_chat_room(self, value):
        """Ensure user has access to this chat room and connection is active"""
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            raise serializers.ValidationError("Authentication required")

        user = request.user
        relationship = value.relationship

        if not relationship.is_chat_allowed():
            raise serializers.ValidationError(
                "Cannot send messages. The connection is not active."
            )

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


class MessageStatusSerializer(serializers.ModelSerializer):
    """Serializer for message read/delivery status"""
    user = UserBasicSerializer(read_only=True)

    class Meta:
        model = MessageStatus
        fields = ['message_status_id', 'message', 'user', 'status', 'timestamp']
        read_only_fields = ['message_status_id', 'timestamp']
