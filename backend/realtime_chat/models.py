from django.db import models
from django.conf import settings
from customer_dashboard.models import CustomerBusinessRelationship


class ChatRoom(models.Model):
    """
    Model to represent a chat room between a customer and a business.
    Each relationship has one chat room.
    """
    chat_room_id = models.AutoField(primary_key=True)
    relationship = models.OneToOneField(
        CustomerBusinessRelationship,
        on_delete=models.CASCADE,
        related_name='chat_room'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chat_room'
        verbose_name = 'Chat Room'
        verbose_name_plural = 'Chat Rooms'
    
    def __str__(self):
        return f"Chat Room {self.chat_room_id}: {self.relationship.customer.user.full_name} <-> {self.relationship.business.business_name}"


class Message(models.Model):
    """
    Model to store individual messages in a chat room.
    """
    MESSAGE_TYPE_CHOICES = [
        ('text', 'Text'),
        ('image', 'Image'),
        ('file', 'File'),
        ('transaction_update', 'Transaction Update'),
        ('system', 'System Message'),
    ]
    
    message_id = models.AutoField(primary_key=True)
    chat_room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    message_type = models.CharField(
        max_length=20,
        choices=MESSAGE_TYPE_CHOICES,
        default='text'
    )
    content = models.TextField(
        help_text="Text content of the message"
    )
    file_url = models.URLField(
        max_length=500,
        null=True,
        blank=True,
        help_text="URL to uploaded file or image (for image/file types)"
    )
    is_edited = models.BooleanField(
        default=False,
        help_text="Whether the message has been edited"
    )
    is_deleted = models.BooleanField(
        default=False,
        help_text="Soft delete flag"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'message'
        verbose_name = 'Message'
        verbose_name_plural = 'Messages'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['chat_room', 'created_at']),
            models.Index(fields=['sender', 'created_at']),
        ]
    
    def __str__(self):
        return f"Message {self.message_id} from {self.sender.full_name} in {self.chat_room}"


class MessageStatus(models.Model):
    """
    Model to track read/delivery status of messages.
    Tracks when a message is delivered and read by the recipient.
    """
    STATUS_CHOICES = [
        ('sent', 'Sent'),
        ('delivered', 'Delivered'),
        ('read', 'Read'),
    ]
    
    message_status_id = models.AutoField(primary_key=True)
    message = models.ForeignKey(
        Message,
        on_delete=models.CASCADE,
        related_name='statuses'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='message_statuses',
        help_text="The user for whom this status applies (recipient)"
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='sent'
    )
    timestamp = models.DateTimeField(
        auto_now_add=True,
        help_text="When the status was achieved"
    )
    
    class Meta:
        db_table = 'message_status'
        verbose_name = 'Message Status'
        verbose_name_plural = 'Message Statuses'
        unique_together = ['message', 'user']
        ordering = ['timestamp']
        indexes = [
            models.Index(fields=['message', 'user']),
            models.Index(fields=['user', 'status']),
        ]
    
    def __str__(self):
        return f"{self.user.full_name} - {self.message.message_id} - {self.status}"
