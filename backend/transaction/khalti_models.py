from django.db import models
from business_dashboard.models import Business


class BusinessKhaltiAccount(models.Model):
    """Model to store business Khalti account details."""

    id = models.AutoField(primary_key=True)
    business = models.OneToOneField(
        Business,
        on_delete=models.CASCADE,
        related_name="khalti_account",
    )
    khalti_id = models.CharField(
        max_length=20,
        help_text="Business Khalti ID (phone number)",
    )
    account_name = models.CharField(
        max_length=255,
        help_text="Name on the Khalti account",
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "business_khalti_account"
        verbose_name = "Business Khalti Account"
        verbose_name_plural = "Business Khalti Accounts"

    def __str__(self):
        return f"{self.business.business_name} - Khalti: {self.khalti_id}"


class KhaltiPaymentRecord(models.Model):
    """Model to record Khalti payments and map them to internal transactions."""

    STATUS_CHOICES = [
        ("initiated", "Initiated"),
        ("success", "Success"),
        ("failed", "Failed"),
        ("verified", "Verified"),
    ]

    id = models.AutoField(primary_key=True)
    transaction = models.OneToOneField(
        "transaction.Transaction",
        on_delete=models.CASCADE,
        related_name="khalti_payment",
        null=True,
        blank=True,
        help_text="Linked internal transaction (created after verification)",
    )
    relationship = models.ForeignKey(
        "customer_dashboard.CustomerBusinessRelationship",
        on_delete=models.CASCADE,
        related_name="khalti_payments",
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    pidx = models.CharField(max_length=255, blank=True, null=True)
    khalti_transaction_id = models.CharField(max_length=255, blank=True, null=True)
    purchase_order_id = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="initiated")
    khalti_response_data = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "khalti_payment_record"
        verbose_name = "Khalti Payment Record"
        verbose_name_plural = "Khalti Payment Records"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Khalti Payment #{self.id} - Rs.{self.amount} ({self.status})"
