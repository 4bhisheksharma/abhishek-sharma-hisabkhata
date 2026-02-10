import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.utils import timezone
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError


class ChatConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for real-time one-to-one chat.
    
    Connection URL: ws://host/ws/chat/<chat_room_id>/?token=<jwt_token>
    
    Message format (send):
    {
        "type": "chat_message",
        "content": "message text",
        "message_type": "text"  # optional, defaults to "text"
    }
    
    Message format (receive):
    {
        "type": "chat_message",
        "message": {
            "message_id": 1,
            "sender_id": 1,
            "sender_name": "John Doe",
            "content": "Hello",
            "message_type": "text",
            "created_at": "2024-01-01T00:00:00Z",
            "is_read": false
        }
    }
    """
    
    async def connect(self):
        """Handle WebSocket connection."""
        self.chat_room_id = self.scope['url_route']['kwargs']['chat_room_id']
        self.room_group_name = f'chat_{self.chat_room_id}'
        self.user = None
        
        # Authenticate user via JWT token from query string
        token = self._get_token_from_query_string()
        if not token:
            await self.close(code=4001)  # Unauthorized - no token
            return
        
        self.user = await self._authenticate_token(token)
        if not self.user:
            await self.close(code=4001)  # Unauthorized - invalid token
            return
        
        # Verify user is participant in this chat room
        is_participant = await self._verify_chat_room_participant()
        if not is_participant:
            await self.close(code=4003)  # Forbidden - not a participant
            return
        
        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
        
        # Send connection confirmation
        await self.send(text_data=json.dumps({
            'type': 'connection_established',
            'message': 'Connected to chat room',
            'chat_room_id': int(self.chat_room_id),
            'user_id': self.user.user_id,
        }))
    
    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        # Leave room group
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
    
    async def receive(self, text_data):
        """Handle incoming WebSocket messages."""
        try:
            data = json.loads(text_data)
            message_type = data.get('type', 'chat_message')
            
            if message_type == 'chat_message':
                await self._handle_chat_message(data)
            elif message_type == 'mark_read':
                await self._handle_mark_read(data)
            elif message_type == 'typing':
                await self._handle_typing(data)
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'Invalid JSON format'
            }))
        except Exception as e:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': str(e)
            }))
    
    async def _handle_chat_message(self, data):
        """Process and broadcast a chat message."""
        content = data.get('content', '').strip()
        msg_type = data.get('message_type', 'text')
        
        if not content:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'Message content cannot be empty'
            }))
            return
        
        # Save message to database
        message = await self._save_message(content, msg_type)
        
        # Broadcast message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': {
                    'message_id': message.message_id,
                    'sender_id': message.sender.user_id,
                    'sender_name': message.sender.full_name,
                    'content': message.content,
                    'message_type': message.message_type,
                    'created_at': message.created_at.isoformat(),
                    'is_read': message.is_read,
                }
            }
        )
    
    async def _handle_mark_read(self, data):
        """Mark messages as read."""
        message_ids = data.get('message_ids', [])
        if message_ids:
            await self._mark_messages_read(message_ids)
            
            # Notify the room that messages were read
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'messages_read',
                    'message_ids': message_ids,
                    'read_by': self.user.user_id,
                    'read_at': timezone.now().isoformat(),
                }
            )
    
    async def _handle_typing(self, data):
        """Broadcast typing indicator."""
        is_typing = data.get('is_typing', False)
        
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'typing_indicator',
                'user_id': self.user.user_id,
                'user_name': self.user.full_name,
                'is_typing': is_typing,
            }
        )
    
    # Channel layer event handlers
    async def chat_message(self, event):
        """Send chat message to WebSocket."""
        await self.send(text_data=json.dumps({
            'type': 'chat_message',
            'message': event['message']
        }))
    
    async def messages_read(self, event):
        """Send read receipt to WebSocket."""
        await self.send(text_data=json.dumps({
            'type': 'messages_read',
            'message_ids': event['message_ids'],
            'read_by': event['read_by'],
            'read_at': event['read_at'],
        }))
    
    async def typing_indicator(self, event):
        """Send typing indicator to WebSocket (exclude sender)."""
        if event['user_id'] != self.user.user_id:
            await self.send(text_data=json.dumps({
                'type': 'typing',
                'user_id': event['user_id'],
                'user_name': event['user_name'],
                'is_typing': event['is_typing'],
            }))
    
    # Helper methods
    def _get_token_from_query_string(self):
        """Extract JWT token from query string."""
        query_string = self.scope.get('query_string', b'').decode()
        params = dict(param.split('=') for param in query_string.split('&') if '=' in param)
        return params.get('token')
    
    @database_sync_to_async
    def _authenticate_token(self, token):
        """Validate JWT token and return user."""
        try:
            from hisabauth.models import User
            access_token = AccessToken(token)
            user_id = access_token['user_id']
            return User.objects.get(user_id=user_id)
        except (InvalidToken, TokenError, User.DoesNotExist):
            return None
    
    @database_sync_to_async
    def _verify_chat_room_participant(self):
        """Verify user is a participant in the chat room."""
        from .models import ChatRoom
        try:
            chat_room = ChatRoom.objects.get(chat_room_id=self.chat_room_id)
            return chat_room.is_participant(self.user)
        except ChatRoom.DoesNotExist:
            return False
    
    @database_sync_to_async
    def _save_message(self, content, message_type):
        """Save message to database."""
        from .models import ChatRoom, Message
        chat_room = ChatRoom.objects.get(chat_room_id=self.chat_room_id)
        message = Message.objects.create(
            chat_room=chat_room,
            sender=self.user,
            content=content,
            message_type=message_type,
        )
        return message
    
    @database_sync_to_async
    def _mark_messages_read(self, message_ids):
        """Mark specified messages as read."""
        from .models import Message
        Message.objects.filter(
            message_id__in=message_ids,
            chat_room_id=self.chat_room_id
        ).exclude(
            sender=self.user  # Don't mark own messages
        ).update(
            is_read=True,
            read_at=timezone.now()
        )
