import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import ChatRoom, Message, MessageStatus

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for real-time chat functionality.
    Handles message sending, receiving, typing indicators, and read receipts.
    """
    
    async def connect(self):
        """Handle WebSocket connection"""
        self.chat_room_id = self.scope['url_route']['kwargs']['chat_room_id']
        self.room_group_name = f'chat_{self.chat_room_id}'
        self.user = self.scope.get('user')
        
        # Verify user is authenticated
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return
        
        # Verify user has access to this chat room
        has_access = await self.verify_chat_room_access()
        if not has_access:
            await self.close()
            return
        
        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
        
        # Notify others that user is online
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'user_status',
                'user_id': self.user.user_id,
                'status': 'online',
                'full_name': self.user.full_name
            }
        )
    
    async def disconnect(self, close_code):
        """Handle WebSocket disconnection"""
        if hasattr(self, 'room_group_name'):
            # Notify others that user is offline
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'user_status',
                    'user_id': self.user.user_id,
                    'status': 'offline',
                    'full_name': self.user.full_name
                }
            )
            
            # Leave room group
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
    
    async def receive(self, text_data):
        """Receive message from WebSocket"""
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'chat_message':
                await self.handle_chat_message(data)
            elif message_type == 'typing':
                await self.handle_typing(data)
            elif message_type == 'message_read':
                await self.handle_message_read(data)
            elif message_type == 'message_delivered':
                await self.handle_message_delivered(data)
            else:
                await self.send(text_data=json.dumps({
                    'error': 'Unknown message type'
                }))
        
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'error': 'Invalid JSON'
            }))
        except Exception as e:
            await self.send(text_data=json.dumps({
                'error': str(e)
            }))
    
    async def handle_chat_message(self, data):
        """Handle incoming chat message"""
        content = data.get('content', '')
        message_type = data.get('message_type', 'text')
        file_url = data.get('file_url')
        
        if not content and message_type == 'text':
            return
        
        # Save message to database
        message = await self.save_message(
            content=content,
            message_type=message_type,
            file_url=file_url
        )
        
        if message:
            # Broadcast message to room group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message_handler',
                    'message_id': message.message_id,
                    'sender_id': self.user.user_id,
                    'sender_name': self.user.full_name,
                    'sender_profile_picture': self.user.profile_picture.url if self.user.profile_picture else None,
                    'message_type': message.message_type,
                    'content': message.content,
                    'file_url': message.file_url,
                    'created_at': message.created_at.isoformat(),
                }
            )
    
    async def handle_typing(self, data):
        """Handle typing indicator"""
        is_typing = data.get('is_typing', False)
        
        # Broadcast typing status to room group (except sender)
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'typing_indicator',
                'user_id': self.user.user_id,
                'user_name': self.user.full_name,
                'is_typing': is_typing
            }
        )
    
    async def handle_message_read(self, data):
        """Handle message read receipt"""
        message_id = data.get('message_id')
        
        if message_id:
            # Update message status
            await self.update_message_status(message_id, 'read')
            
            # Broadcast read receipt
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'message_status_update',
                    'message_id': message_id,
                    'user_id': self.user.user_id,
                    'status': 'read'
                }
            )
    
    async def handle_message_delivered(self, data):
        """Handle message delivered receipt"""
        message_id = data.get('message_id')
        
        if message_id:
            # Update message status
            await self.update_message_status(message_id, 'delivered')
            
            # Broadcast delivery receipt
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'message_status_update',
                    'message_id': message_id,
                    'user_id': self.user.user_id,
                    'status': 'delivered'
                }
            )
    
    # Handlers for group messages
    
    async def chat_message_handler(self, event):
        """Send chat message to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'chat_message',
            'message_id': event['message_id'],
            'sender_id': event['sender_id'],
            'sender_name': event['sender_name'],
            'sender_profile_picture': event['sender_profile_picture'],
            'message_type': event['message_type'],
            'content': event['content'],
            'file_url': event['file_url'],
            'created_at': event['created_at'],
        }))
    
    async def typing_indicator(self, event):
        """Send typing indicator to WebSocket (except to the typer)"""
        if event['user_id'] != self.user.user_id:
            await self.send(text_data=json.dumps({
                'type': 'typing',
                'user_id': event['user_id'],
                'user_name': event['user_name'],
                'is_typing': event['is_typing']
            }))
    
    async def message_status_update(self, event):
        """Send message status update to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'message_status',
            'message_id': event['message_id'],
            'user_id': event['user_id'],
            'status': event['status']
        }))
    
    async def user_status(self, event):
        """Send user online/offline status to WebSocket"""
        if event['user_id'] != self.user.user_id:
            await self.send(text_data=json.dumps({
                'type': 'user_status',
                'user_id': event['user_id'],
                'full_name': event['full_name'],
                'status': event['status']
            }))
    
    # Database operations
    
    @database_sync_to_async
    def verify_chat_room_access(self):
        """Verify that user has access to this chat room and connection is active"""
        try:
            chat_room = ChatRoom.objects.select_related(
                'relationship__customer',
                'relationship__business'
            ).get(chat_room_id=self.chat_room_id)
            
            user = self.user
            relationship = chat_room.relationship
            
            # Check if the relationship/connection is active
            if not relationship.is_chat_allowed():
                return False
            
            # Check if user is customer or business in the relationship
            is_customer = (
                hasattr(user, 'customer_profile') and 
                relationship.customer == user.customer_profile
            )
            is_business = (
                hasattr(user, 'business_profile') and 
                relationship.business == user.business_profile
            )
            
            return is_customer or is_business
        
        except ChatRoom.DoesNotExist:
            return False
    
    @database_sync_to_async
    def save_message(self, content, message_type='text', file_url=None):
        """Save message to database if connection is active"""
        try:
            chat_room = ChatRoom.objects.select_related(
                'relationship'
            ).get(chat_room_id=self.chat_room_id)
            
            # Check if the relationship is active before allowing message send
            if not chat_room.relationship.is_chat_allowed():
                print(f"Cannot send message: Connection is not active")
                return None
            
            message = Message.objects.create(
                chat_room=chat_room,
                sender=self.user,
                message_type=message_type,
                content=content,
                file_url=file_url
            )
            
            # Get the other user (recipient)
            relationship = chat_room.relationship
            if hasattr(self.user, 'customer_profile') and relationship.customer == self.user.customer_profile:
                recipient = relationship.business.user
            elif hasattr(self.user, 'business_profile') and relationship.business == self.user.business_profile:
                recipient = relationship.customer.user
            else:
                recipient = None
            
            # Create initial status for recipient
            if recipient:
                MessageStatus.objects.create(
                    message=message,
                    user=recipient,
                    status='sent'
                )
            
            return message
        
        except Exception as e:
            print(f"Error saving message: {e}")
            return None
    
    @database_sync_to_async
    def update_message_status(self, message_id, status):
        """Update message status in database"""
        try:
            message = Message.objects.get(message_id=message_id)
            
            # Don't update status for own messages
            if message.sender == self.user:
                return False
            
            MessageStatus.objects.update_or_create(
                message=message,
                user=self.user,
                defaults={'status': status}
            )
            return True
        
        except Message.DoesNotExist:
            return False
