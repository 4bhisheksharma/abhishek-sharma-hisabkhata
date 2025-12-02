from django.db import models
from django.utils import timezone
from datetime import timedelta


class PendingRegistration(models.Model):
    """Store registration data until OTP is verified"""
    pending_id = models.AutoField(primary_key=True)
    email = models.EmailField(unique=True)
    password_hash = models.CharField(max_length=128)
    phone_number = models.CharField(max_length=20, null=True, blank=True)
    full_name = models.CharField(max_length=255)
    role = models.CharField(max_length=50)
    business_name = models.CharField(max_length=255, null=True, blank=True)
    preferred_language = models.CharField(max_length=10, default='en')
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    
    class Meta:
        db_table = 'pending_registration'
        ordering = ['-created_at']
        verbose_name = 'Pending Registration'
        verbose_name_plural = 'Pending Registrations'
    
    def __str__(self):
        return f"{self.email} - {self.full_name}"
    
    def is_expired(self):
        """Check if registration has expired (15 minutes)"""
        return timezone.now() > self.expires_at
    
    def save(self, *args, **kwargs):
        """Set expiry time to 15 minutes from creation if not set"""
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(minutes=15)
        super().save(*args, **kwargs)
