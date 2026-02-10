from django.urls import re_path
from . import consumers

# WebSocket URL patterns for chat
websocket_urlpatterns = [
    # Chat room WebSocket connection
    # URL: ws://host/ws/chat/<chat_room_id>/?token=<jwt_token>
    re_path(
        r'ws/chat/(?P<chat_room_id>\d+)/$',
        consumers.ChatConsumer.as_asgi()
    ),
]
