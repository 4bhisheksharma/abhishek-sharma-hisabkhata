import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import ChatRoom, Message, MessageStatus
from customer_dashboard.models import CustomerBusinessRelationship

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for real-time chat
    """
    
    async def connect(self):
        """Handle WebSocket connection"""
        self.user = self.scope['user']
        self.chat_room_id = self.scope['url_route']['kwargs']['chat_room_id']
        self.room_group_name = f'chat_{self.chat_room_id}'
        
        # Check if user is authenticated
        if not self.user.is_authenticated:
            await self.close()
            return
        
        # Verify user has access to this chat room
        has_access = await self.check_user_access()
        if not has_access:
            await self.close()
            return
        
        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
        
        # Send user online status
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'user_status',
                'user_id': self.user.user_id,
                'user_name': self.user.full_name,
                'status': 'online'
            }
        )
    
    async def disconnect(self, close_code):
        """Handle WebSocket disconnection"""
        if hasattr(self, 'room_group_name'):
            # Send user offline status
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'user_status',
                    'user_id': self.user.user_id,
                    'user_name': self.user.full_name,
                    'status': 'offline'
                }
            )
            
            # Leave room group
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
    
    async def receive(self, text_data):
        """Handle incoming WebSocket messages"""
        try:
            data = json.loads(text_data)
            message_type = data.get('type', 'chat_message')
            
            if message_type == 'chat_message':
                await self.handle_chat_message(data)
            elif message_type == 'typing':
                await self.handle_typing(data)
            elif message_type == 'read_receipt':
                await self.handle_read_receipt(data)
            elif message_type == 'edit_message':
                await self.handle_edit_message(data)
            elif message_type == 'delete_message':
                await self.handle_delete_message(data)
                
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'error': 'Invalid JSON format'
            }))
        except Exception as e:
            await self.send(text_data=json.dumps({
                'error': str(e)
            }))
    
    async def handle_chat_message(self, data):
        """Handle new chat message"""
        content = data.get('content', '')
        msg_type = data.get('message_type', 'text')
        file_url = data.get('file_url', '')
        
        if not content:
            return
        
        # Save message to database
        message = await self.save_message(content, msg_type, file_url)
        
        # Get recipient for message status
        recipient = await self.get_recipient()
        
        # Create message status for recipient
        await self.create_message_status(message, recipient)
        
        # Broadcast message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message_broadcast',
                'message_id': message.message_id,
                'sender_id': self.user.user_id,
                'sender_name': self.user.full_name,
                'sender_profile_picture': self.user.profile_picture.url if self.user.profile_picture else None,
                'content': message.content,
                'message_type': message.message_type,
                'file_url': message.file_url,
                'created_at': message.created_at.isoformat(),
            }
        )
    
    async def handle_typing(self, data):
        """Handle typing indicator"""
        is_typing = data.get('is_typing', False)
        
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'typing_indicator',
                'user_id': self.user.user_id,
                'user_name': self.user.full_name,
                'is_typing': is_typing
            }
        )
    
    async def handle_read_receipt(self, data):
        """Handle message read receipt"""
        message_id = data.get('message_id')
        
        if message_id:
            await self.update_message_status(message_id, 'read')
            
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'read_receipt_broadcast',
                    'message_id': message_id,
                    'user_id': self.user.user_id,
                    'status': 'read'
                }
            )
    
    async def handle_edit_message(self, data):
        """Handle message editing"""
        message_id = data.get('message_id')
        new_content = data.get('content', '')
        
        if message_id and new_content:
            success = await self.edit_message(message_id, new_content)
            
            if success:
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'message_edited_broadcast',
                        'message_id': message_id,
                        'new_content': new_content,
                        'user_id': self.user.user_id
                    }
                )
    
    async def handle_delete_message(self, data):
        """Handle message deletion"""
        message_id = data.get('message_id')
        
        if message_id:
            success = await self.delete_message(message_id)
            
            if success:
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'message_deleted_broadcast',
                        'message_id': message_id,
                        'user_id': self.user.user_id
                    }
                )
    
    # Event handlers for broadcasting
    async def chat_message_broadcast(self, event):
        """Send chat message to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'chat_message',
            'message_id': event['message_id'],
            'sender_id': event['sender_id'],
            'sender_name': event['sender_name'],
            'sender_profile_picture': event['sender_profile_picture'],
            'content': event['content'],
            'message_type': event['message_type'],
            'file_url': event['file_url'],
            'created_at': event['created_at']
        }))
    
    async def typing_indicator(self, event):
        """Send typing indicator to WebSocket"""
        # Don't send typing indicator to the sender
        if event['user_id'] != self.user.user_id:
            await self.send(text_data=json.dumps({
                'type': 'typing',
                'user_id': event['user_id'],
                'user_name': event['user_name'],
                'is_typing': event['is_typing']
            }))
    
    async def read_receipt_broadcast(self, event):
        """Send read receipt to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'read_receipt',
            'message_id': event['message_id'],
            'user_id': event['user_id'],
            'status': event['status']
        }))
    
    async def message_edited_broadcast(self, event):
        """Send message edit notification to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'message_edited',
            'message_id': event['message_id'],
            'new_content': event['new_content'],
            'user_id': event['user_id']
        }))
    
    async def message_deleted_broadcast(self, event):
        """Send message deletion notification to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'message_deleted',
            'message_id': event['message_id'],
            'user_id': event['user_id']
        }))
    
    async def user_status(self, event):
        """Send user online/offline status to WebSocket"""
        # Don't send own status to self
        if event['user_id'] != self.user.user_id:
            await self.send(text_data=json.dumps({
                'type': 'user_status',
                'user_id': event['user_id'],
                'user_name': event['user_name'],
                'status': event['status']
            }))
    
    # Database operations
    @database_sync_to_async
    def check_user_access(self):
        """Check if user has access to this chat room"""
        try:
            chat_room = ChatRoom.objects.select_related(
                'relationship__customer__user',
                'relationship__business__user'
            ).get(chat_room_id=self.chat_room_id)
            
            is_customer = hasattr(self.user, 'customer_profile') and chat_room.relationship.customer == self.user.customer_profile
            is_business = hasattr(self.user, 'business_profile') and chat_room.relationship.business == self.user.business_profile
            
            return is_customer or is_business
        except ChatRoom.DoesNotExist:
            return False
    
    @database_sync_to_async
    def save_message(self, content, msg_type, file_url):
        """Save message to database"""
        chat_room = ChatRoom.objects.get(chat_room_id=self.chat_room_id)
        message = Message.objects.create(
            chat_room=chat_room,
            sender=self.user,
            content=content,
            message_type=msg_type,
            file_url=file_url if file_url else ''
        )
        return message
    
    @database_sync_to_async
    def get_recipient(self):
        """Get the recipient user (the other person in the chat)"""
        chat_room = ChatRoom.objects.select_related(
            'relationship__customer__user',
            'relationship__business__user'
        ).get(chat_room_id=self.chat_room_id)
        
        if hasattr(self.user, 'customer_profile') and chat_room.relationship.customer == self.user.customer_profile:
            return chat_room.relationship.business.user
        else:
            return chat_room.relationship.customer.user
    
    @database_sync_to_async
    def create_message_status(self, message, recipient):
        """Create message status for recipient"""
        MessageStatus.objects.create(
            message=message,
            user=recipient,
            status='sent'
        )
    
    @database_sync_to_async
    def update_message_status(self, message_id, status):
        """Update message status"""
        try:
            message_status = MessageStatus.objects.get(
                message_id=message_id,
                user=self.user
            )
            message_status.status = status
            message_status.save()
            return True
        except MessageStatus.DoesNotExist:
            return False
    
    @database_sync_to_async
    def edit_message(self, message_id, new_content):
        """Edit a message"""
        try:
            message = Message.objects.get(
                message_id=message_id,
                sender=self.user,
                chat_room_id=self.chat_room_id
            )
            message.content = new_content
            message.is_edited = True
            message.save()
            return True
        except Message.DoesNotExist:
            return False
    
    @database_sync_to_async
    def delete_message(self, message_id):
        """Soft delete a message"""
        try:
            message = Message.objects.get(
                message_id=message_id,
                sender=self.user,
                chat_room_id=self.chat_room_id
            )
            message.is_deleted = True
            message.save()
            return True
        except Message.DoesNotExist:
            return False
