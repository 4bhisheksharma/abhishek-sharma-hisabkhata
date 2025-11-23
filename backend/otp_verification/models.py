from django.db import models
from django.utils import timezone
from datetime import timedelta


class OTP(models.Model):
    """OTP table for email verification and authentication"""
    otp_id = models.AutoField(primary_key=True)
    email = models.EmailField()
    code = models.CharField(max_length=6)
    is_used = models.BooleanField(default=False)
    max_attempts = models.IntegerField(default=3)
    attempts = models.IntegerField(default=0)
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'otp'
        ordering = ['-created_at']
        verbose_name = 'OTP'
        verbose_name_plural = 'OTPs'
    
    def __str__(self):
        return f"{self.email} - {self.code}"
    
    def is_valid(self):
        """Check if OTP is valid (not used, not expired, and has remaining attempts)"""
        return (
            not self.is_used 
            and self.attempts < self.max_attempts
            and timezone.now() <= self.expires_at
        )
    
    def increment_attempts(self):
        """Increment the number of attempts"""
        self.attempts += 1
        self.save(update_fields=['attempts', 'updated_at'])
    
    def mark_as_used(self):
        """Mark OTP as used"""
        self.is_used = True
        self.save(update_fields=['is_used', 'updated_at'])
    
    def can_resend(self, cooldown_minutes=1):
        """Check if enough time has passed to resend OTP"""
        cooldown_period = timedelta(minutes=cooldown_minutes)
        return timezone.now() >= (self.created_at + cooldown_period)
    
    def save(self, *args, **kwargs):
        """Set expiry time to 10 minutes from creation if not set"""
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(minutes=10)
        super().save(*args, **kwargs)
