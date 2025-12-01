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