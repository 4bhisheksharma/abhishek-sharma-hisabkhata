from django.db import models
from customer_dashboard.models import CustomerBusinessRelationship


class Transaction(models.Model):
    """
    Model to store transactions between customers and businesses.
    Positive amount = customer owes business (purchase/credit given)
    Negative amount = business owes customer (payment received/refund)
    """
    TRANSACTION_TYPE_CHOICES = [
        ('purchase', 'Purchase'),      # Customer bought something (increases debt)
        ('payment', 'Payment'),        # Customer paid (decreases debt)
        ('credit', 'Credit Given'),    # Business gave credit (increases debt)
        ('refund', 'Refund'),          # Business refunded (decreases debt)
        ('adjustment', 'Adjustment'),  # Manual adjustment
    ]
    
    transaction_id = models.AutoField(primary_key=True)
    relationship = models.ForeignKey(
        CustomerBusinessRelationship,
        on_delete=models.CASCADE,
        related_name='transactions'
    )
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        help_text="Positive = customer owes more, Negative = customer paid/refund"
    )
    transaction_type = models.CharField(
        max_length=20,
        choices=TRANSACTION_TYPE_CHOICES,
        default='purchase'
    )
    description = models.CharField(
        max_length=255,
        blank=True,
        help_text="Description or name of the transaction"
    )
    transaction_date = models.DateTimeField(
        auto_now_add=True,
        help_text="Date when transaction occurred"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'transaction'
        verbose_name = 'Transaction'
        verbose_name_plural = 'Transactions'
        ordering = ['-transaction_date']
    
    def __str__(self):
        return f"Transaction {self.transaction_id}: {self.transaction_type} - Rs.{self.amount}"
    
    def save(self, *args, **kwargs):
        """Update the pending_due in relationship after saving transaction"""
        super().save(*args, **kwargs)
        # Recalculate pending_due based on all transactions
        self.relationship.update_pending_due()


class Favorite(models.Model):
    """
    Model to store customer's favorite businesses.
    Only customers can favorite businesses.
    """
    favorite_id = models.AutoField(primary_key=True)
    customer = models.ForeignKey(
        'customer_dashboard.Customer',
        on_delete=models.CASCADE,
        related_name='favorites'
    )
    business = models.ForeignKey(
        'business_dashboard.Business',
        on_delete=models.CASCADE,
        related_name='favorited_by'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'favorite'
        verbose_name = 'Favorite'
        verbose_name_plural = 'Favorites'
        unique_together = ['customer', 'business']
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.customer.user.full_name} favorites {self.business.business_name}"
