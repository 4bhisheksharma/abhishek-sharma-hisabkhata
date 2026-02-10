from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatRoomViewSet, MessageCreateView

# Create router for ViewSets
router = DefaultRouter()
router.register(r'chat-rooms', ChatRoomViewSet, basename='chatroom')

urlpatterns = [
    # Include router URLs
    path('', include(router.urls)),
    
    # Message creation endpoint (REST fallback)
    path('messages/', MessageCreateView.as_view(), name='message-create'),
]
