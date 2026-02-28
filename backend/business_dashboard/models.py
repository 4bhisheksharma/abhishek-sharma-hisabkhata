from django.db import models
from hisabauth.models import User


class Business(models.Model):
    """Business Profile"""
    business_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='business_profile'
    )
    business_name = models.CharField(max_length=255)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'business'
        verbose_name = 'Business'
        verbose_name_plural = 'Businesses'
    
    def __str__(self):
        return f"Business: {self.business_name}"


class BusinessVerificationRequest(models.Model):
    """Verification request submitted by a business with shop documents"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    id = models.AutoField(primary_key=True)
    business = models.ForeignKey(
        Business,
        on_delete=models.CASCADE,
        related_name='verification_requests'
    )
    document = models.FileField(
        upload_to='verification_documents/',
        help_text='Business shop document (e.g. registration certificate, PAN, license)'
    )
    document_type = models.CharField(
        max_length=100,
        help_text='Type of document submitted',
        default='business_registration'
    )
    note = models.TextField(
        blank=True,
        null=True,
        help_text='Optional note from the business owner'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    admin_remarks = models.TextField(
        blank=True,
        null=True,
        help_text='Remarks from admin after reviewing the document'
    )
    reviewed_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_verifications'
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'business_verification_request'
        verbose_name = 'Business Verification Request'
        verbose_name_plural = 'Business Verification Requests'
        ordering = ['-created_at']

    def __str__(self):
        return f"Verification Request #{self.id} - {self.business.business_name} ({self.status})"