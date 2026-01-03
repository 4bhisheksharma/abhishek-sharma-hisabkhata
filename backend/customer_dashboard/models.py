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
    
    def update_pending_due(self):
        """Recalculate pending_due based on all transactions"""
        from django.db.models import Sum
        total = self.transactions.aggregate(total=Sum('amount'))['total'] or 0
        self.pending_due = total
        self.save(update_fields=['pending_due', 'updated_at'])
    
    def get_total_paid(self):
        """Get total amount paid by customer (negative transactions)"""
        from django.db.models import Sum
        paid = self.transactions.filter(
            transaction_type__in=['payment']
        ).aggregate(total=Sum('amount'))['total'] or 0
        return abs(paid)
    
    def get_total_purchases(self):
        """Get total purchases/credits (positive transactions)"""
        from django.db.models import Sum
        purchases = self.transactions.filter(
            transaction_type__in=['purchase', 'credit']
        ).aggregate(total=Sum('amount'))['total'] or 0
        return purchases