from django.db import models
from django.conf import settings


class Notification(models.Model):
    """
    Model to handle in-app notifications
    """
    
    notification_id = models.AutoField(primary_key=True)
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_notifications'
    )
    receiver = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_notifications'
    )
    title = models.CharField(max_length=255)
    message = models.TextField()
    type = models.CharField(max_length=50)
    is_read = models.BooleanField(default=False) #dont sure about this
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['receiver', 'is_read']),
            models.Index(fields=['receiver', 'created_at']),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.receiver.email}"

