from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ChatRoomViewSet,
    MessageViewSet,
    ChatRoomMessagesView
)

app_name = 'realtime_chat'

# Create router for viewsets
router = DefaultRouter()
router.register(r'chat-rooms', ChatRoomViewSet, basename='chatroom')
router.register(r'messages', MessageViewSet, basename='message')

urlpatterns = [
    # Router URLs
    path('', include(router.urls)),
    
    # Additional custom endpoints
    path('chat-rooms/<int:chat_room_id>/messages/', 
         ChatRoomMessagesView.as_view(), 
         name='chatroom-messages'),
]
