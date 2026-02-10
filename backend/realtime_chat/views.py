from rest_framework import status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from django.db.models import Q
from .models import ChatRoom, Message
from .serializers import (
    ChatRoomSerializer,
    ChatRoomCreateSerializer,
    MessageSerializer,
    MessageCreateSerializer,
)


class ChatRoomViewSet(ModelViewSet):
    """
    ViewSet for managing chat rooms.
    
    Endpoints:
    - GET /chat/chat-rooms/ - List all chat rooms for current user
    - POST /chat/chat-rooms/get_or_create/ - Get or create chat room with another user
    - GET /chat/chat-rooms/<id>/ - Get chat room details
    - GET /chat/chat-rooms/<id>/messages/ - Get messages for a chat room
    - POST /chat/chat-rooms/<id>/mark_as_read/ - Mark all messages in room as read
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ChatRoomSerializer
    
    def get_queryset(self):
        """Get chat rooms where current user is a participant."""
        user = self.request.user
        return ChatRoom.objects.filter(
            Q(participant_one=user) | Q(participant_two=user)
        ).select_related('participant_one', 'participant_two')
    
    def get_serializer_context(self):
        """Add request to serializer context."""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    @action(detail=False, methods=['post'])
    def get_or_create(self, request):
        """
        Get or create a chat room with another user.
        
        Request body:
        {
            "other_user_id": 123
        }
        """
        serializer = ChatRoomCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        chat_room = serializer.save()
        
        response_serializer = ChatRoomSerializer(
            chat_room,
            context={'request': request}
        )
        return Response(response_serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['get'])
    def messages(self, request, pk=None):
        """
        Get messages for a chat room with pagination.
        
        Query params:
        - limit: Number of messages to return (default: 50)
        - before: Get messages before this message_id (for pagination)
        """
        chat_room = self.get_object()
        
        # Verify user is participant
        if not chat_room.is_participant(request.user):
            return Response(
                {'message': 'You are not a participant in this chat room'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        limit = int(request.query_params.get('limit', 50))
        before_id = request.query_params.get('before')
        
        messages = chat_room.messages.select_related('sender')
        
        if before_id:
            messages = messages.filter(message_id__lt=before_id)
        
        # Get messages in reverse order (newest first for pagination)
        # then reverse for display (oldest first)
        messages = messages.order_by('-created_at')[:limit]
        messages = list(reversed(messages))
        
        serializer = MessageSerializer(messages, many=True)
        return Response({
            'messages': serializer.data,
            'has_more': len(messages) == limit,
        })
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark all messages in chat room as read for current user."""
        chat_room = self.get_object()
        
        if not chat_room.is_participant(request.user):
            return Response(
                {'message': 'You are not a participant in this chat room'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Mark messages from other user as read
        updated_count = Message.objects.filter(
            chat_room=chat_room
        ).exclude(
            sender=request.user
        ).filter(
            is_read=False
        ).update(
            is_read=True,
            read_at=__import__('django.utils', fromlist=['timezone']).timezone.now()
        )
        
        return Response({
            'message': 'Messages marked as read',
            'updated_count': updated_count
        })


class MessageCreateView(APIView):
    """
    Create a new message via REST API.
    Note: For real-time messaging, use WebSocket instead.
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        """
        Create a new message.
        
        Request body:
        {
            "chat_room": 123,
            "content": "Hello!",
            "message_type": "text"  // optional
        }
        """
        serializer = MessageCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        
        # Verify user is participant in the chat room
        chat_room = serializer.validated_data['chat_room']
        if not chat_room.is_participant(request.user):
            return Response(
                {'message': 'You are not a participant in this chat room'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        message = serializer.save()
        response_serializer = MessageSerializer(message)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)
