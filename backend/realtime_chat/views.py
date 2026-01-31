from django.shortcuts import get_object_or_404
from django.db.models import Q, Prefetch, Max
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination

from .models import ChatRoom, Message, MessageStatus
from .serializers import (
    ChatRoomSerializer,
    ChatRoomDetailSerializer,
    MessageSerializer,
    MessageCreateSerializer,
    MessageUpdateSerializer,
    MessageStatusSerializer
)
from .permissions import IsChatRoomParticipant, IsMessageSender, CanAccessChatRoom


class MessagePagination(PageNumberPagination):
    """Custom pagination for messages"""
    page_size = 50
    page_size_query_param = 'page_size'
    max_page_size = 100


class ChatRoomViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for listing and retrieving chat rooms.
    Users can only see chat rooms they are part of.
    """
    permission_classes = [IsAuthenticated, CanAccessChatRoom]
    serializer_class = ChatRoomSerializer
    
    def get_queryset(self):
        """
        Filter chat rooms to only show those the user is part of.
        """
        user = self.request.user
        
        # Get chat rooms where user is either customer or business
        queryset = ChatRoom.objects.select_related(
            'relationship__customer__user',
            'relationship__business__user'
        ).prefetch_related(
            Prefetch(
                'messages',
                queryset=Message.objects.filter(is_deleted=False).order_by('-created_at')[:1]
            )
        )
        
        # Filter by user's role
        if hasattr(user, 'customer_profile'):
            queryset = queryset.filter(
                relationship__customer=user.customer_profile
            )
        elif hasattr(user, 'business_profile'):
            queryset = queryset.filter(
                relationship__business=user.business_profile
            )
        else:
            # User has neither role, return empty queryset
            queryset = queryset.none()
        
        # Order by most recent activity
        queryset = queryset.annotate(
            last_message_time=Max('messages__created_at')
        ).order_by('-last_message_time')
        
        return queryset
    
    def get_serializer_class(self):
        """Use detailed serializer for retrieve action"""
        if self.action == 'retrieve':
            return ChatRoomDetailSerializer
        return ChatRoomSerializer
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """
        Mark all messages in the chat room as read for the current user.
        """
        chat_room = self.get_object()
        user = request.user
        
        # Get all unread messages in this chat room (not sent by current user)
        unread_messages = Message.objects.filter(
            chat_room=chat_room,
            is_deleted=False
        ).exclude(sender=user)
        
        # Update or create message status for each unread message
        for message in unread_messages:
            MessageStatus.objects.update_or_create(
                message=message,
                user=user,
                defaults={'status': 'read'}
            )
        
        return Response({
            'status': 'success',
            'message': f'Marked {unread_messages.count()} messages as read'
        })
    
    @action(detail=False, methods=['get'])
    def unread_summary(self, request):
        """
        Get summary of unread messages across all chat rooms.
        """
        chat_rooms = self.get_queryset()
        total_unread = 0
        
        for chat_room in chat_rooms:
            serializer = self.get_serializer(chat_room)
            total_unread += serializer.data.get('unread_count', 0)
        
        return Response({
            'total_unread': total_unread,
            'chat_rooms_count': chat_rooms.count()
        })


class MessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for creating, reading, updating, and deleting messages.
    """
    permission_classes = [IsAuthenticated, IsChatRoomParticipant]
    pagination_class = MessagePagination
    
    def get_queryset(self):
        """
        Filter messages based on user's accessible chat rooms.
        """
        user = self.request.user
        chat_room_id = self.request.query_params.get('chat_room_id')
        
        # Base queryset: only non-deleted messages
        queryset = Message.objects.filter(
            is_deleted=False
        ).select_related(
            'sender',
            'chat_room__relationship__customer__user',
            'chat_room__relationship__business__user'
        ).prefetch_related('statuses__user')
        
        # Filter by chat room if specified
        if chat_room_id:
            queryset = queryset.filter(chat_room_id=chat_room_id)
        
        # Filter by user's accessible chat rooms
        if hasattr(user, 'customer_profile'):
            queryset = queryset.filter(
                chat_room__relationship__customer=user.customer_profile
            )
        elif hasattr(user, 'business_profile'):
            queryset = queryset.filter(
                chat_room__relationship__business=user.business_profile
            )
        else:
            queryset = queryset.none()
        
        return queryset.order_by('created_at')
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action"""
        if self.action == 'create':
            return MessageCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return MessageUpdateSerializer
        return MessageSerializer
    
    def perform_create(self, serializer):
        """Create message and set initial status"""
        message = serializer.save()
        
        # Get the other user in the chat (recipient)
        user = self.request.user
        relationship = message.chat_room.relationship
        
        if hasattr(user, 'customer_profile') and relationship.customer == user.customer_profile:
            recipient = relationship.business.user
        elif hasattr(user, 'business_profile') and relationship.business == user.business_profile:
            recipient = relationship.customer.user
        else:
            recipient = None
        
        # Create initial status for recipient as 'sent'
        if recipient:
            MessageStatus.objects.create(
                message=message,
                user=recipient,
                status='sent'
            )
    
    def perform_update(self, serializer):
        """Only allow sender to update their own message"""
        message = self.get_object()
        if message.sender != self.request.user:
            raise PermissionError("You can only edit your own messages")
        serializer.save()
    
    def perform_destroy(self, instance):
        """Soft delete: mark as deleted instead of actually deleting"""
        if instance.sender != self.request.user:
            raise PermissionError("You can only delete your own messages")
        instance.is_deleted = True
        instance.save()
    
    @action(detail=True, methods=['post'])
    def mark_as_delivered(self, request, pk=None):
        """Mark a message as delivered to the current user"""
        message = self.get_object()
        user = request.user
        
        # Don't update status for own messages
        if message.sender == user:
            return Response(
                {'error': 'Cannot mark own message as delivered'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        status_obj, created = MessageStatus.objects.update_or_create(
            message=message,
            user=user,
            defaults={'status': 'delivered'}
        )
        
        serializer = MessageStatusSerializer(status_obj)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Mark a message as read by the current user"""
        message = self.get_object()
        user = request.user
        
        # Don't update status for own messages
        if message.sender == user:
            return Response(
                {'error': 'Cannot mark own message as read'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        status_obj, created = MessageStatus.objects.update_or_create(
            message=message,
            user=user,
            defaults={'status': 'read'}
        )
        
        serializer = MessageStatusSerializer(status_obj)
        return Response(serializer.data)


class ChatRoomMessagesView(generics.ListAPIView):
    """
    Get all messages for a specific chat room with pagination.
    """
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated, IsChatRoomParticipant]
    pagination_class = MessagePagination
    
    def get_queryset(self):
        """Get messages for the specified chat room"""
        chat_room_id = self.kwargs.get('chat_room_id')
        chat_room = get_object_or_404(ChatRoom, pk=chat_room_id)
        
        # Check permission
        self.check_object_permissions(self.request, chat_room)
        
        return Message.objects.filter(
            chat_room=chat_room,
            is_deleted=False
        ).select_related('sender').prefetch_related('statuses__user').order_by('created_at')

