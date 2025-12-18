from django.db import models
from business.models import Business
from customer.models import Customer


class BusinessCustomerRequest(models.Model):
    """
    Model to handle requests between businesses and customers
    """
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
    ]
    
    business_customer_request_id = models.AutoField(primary_key=True)
    business = models.ForeignKey(
        Business,
        on_delete=models.CASCADE,
        related_name='customer_requests'
    )
    customer = models.ForeignKey(
        Customer,
        on_delete=models.CASCADE,
        related_name='business_requests'
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
        unique_together = ['business', 'customer']
        indexes = [
            models.Index(fields=['business', 'status']),
            models.Index(fields=['customer', 'status']),
        ]
    
    def __str__(self):
        return f"Request {self.business_customer_request_id}: {self.business.business_name} -> {self.customer.user.email} ({self.status})"

