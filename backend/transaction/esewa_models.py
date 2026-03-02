from django.db import models
from business_dashboard.models import Business


class BusinessEsewaAccount(models.Model):
    """
    Model to store business eSewa account details.
    Businesses must link their eSewa account before customers can pay via eSewa.
    """
    id = models.AutoField(primary_key=True)
    business = models.OneToOneField(
        Business,
        on_delete=models.CASCADE,
        related_name='esewa_account'
    )
    esewa_id = models.CharField(
        max_length=20,
        help_text="Business eSewa ID (phone number)"
    )
    account_name = models.CharField(
        max_length=255,
        help_text="Name on the eSewa account"
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'business_esewa_account'
        verbose_name = 'Business eSewa Account'
        verbose_name_plural = 'Business eSewa Accounts'

    def __str__(self):
        return f"{self.business.business_name} - eSewa: {self.esewa_id}"


class EsewaPaymentRecord(models.Model):
    """
    Model to record eSewa payments made by customers to businesses.
    Links an eSewa transaction to an internal Transaction record.
    """
    STATUS_CHOICES = [
        ('initiated', 'Initiated'),
        ('success', 'Success'),
        ('failed', 'Failed'),
        ('verified', 'Verified'),
    ]

    id = models.AutoField(primary_key=True)
    transaction = models.OneToOneField(
        'transaction.Transaction',
        on_delete=models.CASCADE,
        related_name='esewa_payment',
        null=True,
        blank=True,
        help_text="Linked internal transaction (created after verification)"
    )
    relationship = models.ForeignKey(
        'customer_dashboard.CustomerBusinessRelationship',
        on_delete=models.CASCADE,
        related_name='esewa_payments'
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    esewa_ref_id = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        help_text="eSewa transaction reference ID"
    )
    esewa_product_id = models.CharField(
        max_length=255,
        help_text="Unique product ID sent to eSewa"
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='initiated'
    )
    esewa_response_data = models.JSONField(
        null=True,
        blank=True,
        help_text="Full response data from eSewa"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'esewa_payment_record'
        verbose_name = 'eSewa Payment Record'
        verbose_name_plural = 'eSewa Payment Records'
        ordering = ['-created_at']

    def __str__(self):
        return f"eSewa Payment #{self.id} - Rs.{self.amount} ({self.status})"
