from django.db import models
from django.conf import settings


class NotificationType(models.TextChoices):
    """All notification types supported by the system"""
    # Connection-related
    CONNECTION_REQUEST = 'connection_request', 'Connection Request'
    CONNECTION_ACCEPTED = 'connection_request_accepted', 'Connection Accepted'
    CONNECTION_REJECTED = 'connection_request_rejected', 'Connection Rejected'
    CONNECTION_DELETED = 'connection_deleted', 'Connection Deleted'
    CONNECTION_CANCELLED = 'connection_request_cancelled', 'Connection Cancelled'
    # Transaction-related
    TRANSACTION_ADDED = 'transaction_added', 'Transaction Added'
    PAYMENT_RECEIVED = 'payment_received', 'Payment Received'
    # Reminders & limits
    DUE_REMINDER = 'due_reminder', 'Due Reminder'
    MONTHLY_LIMIT_EXCEEDED = 'monthly_limit_exceeded', 'Monthly Limit Exceeded'
    BULK_PAYMENT_REMINDER = 'bulk_payment_reminder', 'Bulk Payment Reminder'
    # Favorites & loyalty
    FAVORITE_ADDED = 'favorite_added', 'Favorite Added'
    LOYALTY_POINTS = 'loyalty_points', 'Loyalty Points'
    # Business verification
    VERIFICATION_APPROVED = 'verification_approved', 'Verification Approved'
    VERIFICATION_REJECTED = 'verification_rejected', 'Verification Rejected'
    # System / broadcast
    BROADCAST = 'broadcast', 'Broadcast'
    SYSTEM = 'system', 'System'


class Notification(models.Model):
    """
    Model to handle in-app notifications.
    Supports both user-to-user and system-generated notifications.
    """
    
    notification_id = models.AutoField(primary_key=True)
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_notifications',
        null=True,
        blank=True,
        help_text="Null for system-generated notifications (broadcast, reminders, etc.)"
    )
    receiver = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_notifications'
    )
    title = models.CharField(max_length=255)
    message = models.TextField()
    type = models.CharField(
        max_length=50,
        choices=NotificationType.choices,
        db_index=True,
    )
    data = models.JSONField(
        null=True,
        blank=True,
        help_text="Extra payload (relationship_id, amount, etc.)"
    )
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['receiver', 'is_read']),
            models.Index(fields=['receiver', 'created_at']),
            models.Index(fields=['type']),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.receiver.email}"

