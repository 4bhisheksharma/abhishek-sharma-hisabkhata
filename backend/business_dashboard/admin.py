from django.contrib import admin
from business_dashboard.models import Business

@admin.register(Business)
class BusinessAdmin(admin.ModelAdmin):
    list_display = ['business_id', 'business_name', 'is_verified', 'created_at', 'updated_at']
    list_filter = ['is_verified', 'created_at']
    search_fields = ['business_name', 'user__email', 'user__full_name']
    readonly_fields = ['business_id', 'created_at', 'updated_at']
    
    # Allow admin to edit business verification status
    list_editable = ['is_verified']
    
    fieldsets = (
        ('Business Information', {
            'fields': ('business_id', 'business_name')
        }),
        ('Verification Status', {
            'fields': ('is_verified',),
            'description': 'Admin can verify or unverify businesses'
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )