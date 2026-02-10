from django.db import models
from django.utils import timezone
from hisabauth.models import User


class ChatRoom(models.Model):
    """
    Represents a one-to-one chat room between two users.
    A chat room is created when two connected users initiate a conversation.
    """
    chat_room_id = models.AutoField(primary_key=True)
    
    # Participants - always two users for one-to-one chat
    participant_one = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='chat_rooms_as_participant_one'
    )
    participant_two = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='chat_rooms_as_participant_two'
    )
    
    # Track last activity for sorting
    last_message_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chat_room'
        verbose_name = 'Chat Room'
        verbose_name_plural = 'Chat Rooms'
        ordering = ['-last_message_at', '-created_at']
        # Ensure unique chat room per pair of users
        unique_together = [['participant_one', 'participant_two']]
    
    def __str__(self):
        return f"Chat: {self.participant_one.full_name} & {self.participant_two.full_name}"
    
    def get_other_participant(self, user):
        """Get the other participant in the chat room."""
        if self.participant_one == user:
            return self.participant_two
        return self.participant_one
    
    def is_participant(self, user):
        """Check if user is a participant in this chat room."""
        return user in [self.participant_one, self.participant_two]
    
    def get_unread_count(self, user):
        """Get count of unread messages for a specific user."""
        return self.messages.filter(is_read=False).exclude(sender=user).count()
    
    @classmethod
    def get_or_create_room(cls, user1, user2):
        """
        Get existing chat room or create new one between two users.
        Ensures consistent ordering to avoid duplicate rooms.
        """
        # Order by user_id to ensure consistent participant order
        if user1.user_id > user2.user_id:
            user1, user2 = user2, user1
        
        room, created = cls.objects.get_or_create(
            participant_one=user1,
            participant_two=user2
        )
        return room, created


class Message(models.Model):
    """
    Represents a single message in a chat room.
    """
    MESSAGE_TYPE_CHOICES = [
        ('text', 'Text'),
        ('image', 'Image'),
        ('system', 'System'),  # For system notifications like "user joined"
    ]
    
    message_id = models.AutoField(primary_key=True)
    chat_room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    
    # Message content
    content = models.TextField()
    message_type = models.CharField(
        max_length=10,
        choices=MESSAGE_TYPE_CHOICES,
        default='text'
    )
    
    # Read status
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chat_message'
        verbose_name = 'Message'
        verbose_name_plural = 'Messages'
        ordering = ['created_at']
    
    def __str__(self):
        return f"{self.sender.full_name}: {self.content[:50]}"
    
    def mark_as_read(self):
        """Mark message as read."""
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save(update_fields=['is_read', 'read_at', 'updated_at'])
    
    def save(self, *args, **kwargs):
        """Override save to update chat room's last_message_at."""
        is_new = self.pk is None
        super().save(*args, **kwargs)
        
        # Update chat room's last message timestamp
        if is_new:
            self.chat_room.last_message_at = self.created_at
            self.chat_room.save(update_fields=['last_message_at', 'updated_at'])
