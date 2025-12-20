from django.contrib import admin
from .models import BusinessCustomerRequest


@admin.register(BusinessCustomerRequest)
class BusinessCustomerRequestAdmin(admin.ModelAdmin):
    list_display = [
        'business_customer_request_id',
        'sender',
        'receiver',
        'status',
        'created_at',
        'updated_at'
    ]
    list_filter = ['status', 'created_at']
    search_fields = ['sender__email', 'receiver__email', 'sender__full_name', 'receiver__full_name']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']

