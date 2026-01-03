from django.db import models
from hisabauth.models import User


class Customer(models.Model):
    """Customer Profile"""
    customer_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='customer_profile'
    )
    status = models.CharField(
        max_length=20,
        default='active',
        choices=[
            ('active', 'Active'),
            ('inactive', 'Inactive'),
            ('suspended', 'Suspended'),
        ]
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'customer'
        verbose_name = 'Customer'
        verbose_name_plural = 'Customers'
    
    def __str__(self):
        return f"Customer: {self.user.full_name}"


class CustomerBusinessRelationship(models.Model):
    """
    Model to track relationships between customers and businesses
    Created when a connection request is accepted
    """
    relationship_id = models.AutoField(primary_key=True)
    customer = models.ForeignKey(
        Customer,
        on_delete=models.CASCADE,
        related_name='business_relationships'
    )
    business = models.ForeignKey(
        'business_dashboard.Business',
        on_delete=models.CASCADE,
        related_name='customer_relationships'
    )
    pending_due = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=0.00,
        help_text="Positive means customer owes business, negative means business owes customer"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'customer_business_relationship'
        verbose_name = 'Customer-Business Relationship'
        verbose_name_plural = 'Customer-Business Relationships'
        unique_together = ('customer', 'business')
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.customer.user.full_name} - {self.business.business_name}"