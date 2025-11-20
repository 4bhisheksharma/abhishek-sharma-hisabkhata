from django.contrib import admin
from .models import OTP


@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    list_display = ['user', 'otp_code', 'purpose', 'is_used', 'created_at', 'expires_at', 'is_valid']
    list_filter = ['purpose', 'is_used', 'created_at']
    search_fields = ['user__email', 'otp_code']
    readonly_fields = ['created_at', 'expires_at']
    
    def is_valid(self, obj):
        return obj.is_valid()
    is_valid.boolean = True
    is_valid.short_description = 'Valid'
