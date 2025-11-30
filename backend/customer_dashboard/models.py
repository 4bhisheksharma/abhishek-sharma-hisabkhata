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


class LoyaltyPoint(models.Model):
    """Gazab Customer Points - Loyalty points for customers"""
    loyalty_point_id = models.AutoField(primary_key=True)
    customer = models.OneToOneField(
        Customer,
        on_delete=models.CASCADE,
        related_name='loyalty_points'
    )
    points = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'loyalty_point'
        verbose_name = 'Loyalty Point'
        verbose_name_plural = 'Loyalty Points'
    
    def __str__(self):
        return f"{self.customer.user.full_name}: {self.points} points"


class FavoriteShop(models.Model):
    """Customer's favorite shops for quick access"""
    favorite_id = models.AutoField(primary_key=True)
    customer = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='favorite_shops'
    )
    shop = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='favorited_by'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'favorite_shop'
        verbose_name = 'Favorite Shop'
        verbose_name_plural = 'Favorite Shops'
        unique_together = ('customer', 'shop')
    
    def __str__(self):
        return f"{self.customer.full_name} → {self.shop.full_name}"