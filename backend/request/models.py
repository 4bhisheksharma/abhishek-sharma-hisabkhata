from django.db import models
from django.conf import settings


class BusinessCustomerRequest(models.Model):
    """
    Model to handle connection requests between users
    Any user can send a request to any other user
    """
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
    ]
    
    business_customer_request_id = models.AutoField(primary_key=True)
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_requests'
    )
    receiver = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_requests'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'business_customer_request'
        ordering = ['-created_at']
        unique_together = ['sender', 'receiver']
        indexes = [
            models.Index(fields=['sender', 'status']),
            models.Index(fields=['receiver', 'status']),
        ]
    
    def __str__(self):
        return f"Request {self.business_customer_request_id}: {self.sender.email} -> {self.receiver.email} ({self.status})"

