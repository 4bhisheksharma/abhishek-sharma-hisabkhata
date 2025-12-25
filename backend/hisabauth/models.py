from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.utils import timezone
from .manager import UserManager


class Role(models.Model):
    """Role table"""
    role_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'role'
        verbose_name = 'Role'
        verbose_name_plural = 'Roles'
    
    def __str__(self):
        return self.name


class User(AbstractBaseUser, PermissionsMixin):
    """User table - main authentication model"""
    user_id = models.AutoField(primary_key=True) #TODO: refine garna chha thorai
    otp = models.ForeignKey(
        'otp_verification.OTP',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='users'
    )
    email = models.EmailField(max_length=255, unique=True)
    password = models.CharField(max_length=128)
    phone_number = models.CharField(max_length=20, unique=True, null=True, blank=True)
    full_name = models.CharField(max_length=255)
    profile_picture = models.ImageField(
        upload_to='profile_pictures/',
        null=True,
        blank=True
    )
    preferred_language = models.CharField(
        max_length=10,
        default='en',
        choices=[
            ('en', 'English'),
            ('ne', 'Nepali'),
        ]
    )
    is_active = models.BooleanField(default=False)
    is_premium = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']
    
    objects = UserManager()
    
    class Meta:
        db_table = 'user'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
    
    @property
    def id(self):
        """Alias for user_id to support JWT and other packages"""
        return self.user_id
    
    @property
    def pk(self):
        """Primary key property"""
        return self.user_id
    
    def __str__(self):
        return f"{self.full_name} ({self.email})"


class UserRole(models.Model):
    """UserRole table - junction table for User and Role"""
    user_role_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='user_roles'
    )
    role = models.ForeignKey(
        Role,
        on_delete=models.CASCADE,
        related_name='user_roles'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_role'
        verbose_name = 'User Role'
        verbose_name_plural = 'User Roles'
        unique_together = ('user', 'role')
    
    def __str__(self):
        return f"{self.user.full_name} - {self.role.name}"