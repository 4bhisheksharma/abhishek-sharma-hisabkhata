from django.db import models
from hisabauth.models import User


class CustomerManager(models.Manager):
    """Custom manager for Customer model"""
    
    def get_monthly_spending_overview(self, customer):
        """Get overall monthly spending across all businesses for a customer"""
        from django.db.models import Sum
        from django.utils import timezone
        import calendar
        
        now = timezone.now()
        # Get first and last day of current month
        first_day = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        last_day = now.replace(
            day=calendar.monthrange(now.year, now.month)[1],
            hour=23, minute=59, second=59, microsecond=999999
        )
        
        # Get all relationships for this customer
        relationships = CustomerBusinessRelationship.objects.filter(customer=customer)
        
        total_spent = 0
        business_count = relationships.count()
        
        for relationship in relationships:
            monthly_spent = relationship.transactions.filter(
                transaction_date__gte=first_day,
                transaction_date__lte=last_day,
                amount__gt=0  # Only count amounts customer owes (purchases/credits)
            ).aggregate(total=Sum('amount'))['total'] or 0
            
            total_spent += monthly_spent
        
        # Check against customer's monthly limit
        monthly_limit = customer.monthly_limit
        is_over_budget = monthly_limit > 0 and total_spent > monthly_limit
        remaining_budget = (monthly_limit - total_spent) if monthly_limit > 0 else None
        
        return {
            'total_spent': total_spent,
            'monthly_limit': monthly_limit if monthly_limit > 0 else None,
            'remaining_budget': remaining_budget,
            'is_over_budget': is_over_budget,
            'business_count': business_count,
            'month': now.strftime('%B %Y'),
            'days_remaining': (last_day - now).days + 1
        }


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
    monthly_limit = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0.00,
        help_text="Overall monthly spending limit set by customer. 0 means no limit."
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    objects = CustomerManager()
    
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