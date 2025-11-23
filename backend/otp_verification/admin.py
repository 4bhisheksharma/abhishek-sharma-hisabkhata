from django.contrib import admin
from .models import OTP


@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    list_display = ['otp_id', 'email', 'code', 'is_used', 'attempts', 'created_at', 'expires_at', 'is_valid_display']
    list_filter = ['is_used', 'created_at']
    search_fields = ['email', 'code']
    readonly_fields = ['otp_id', 'created_at', 'expires_at']
    
    def is_valid_display(self, obj):
        return obj.is_valid()
    is_valid_display.boolean = True
    is_valid_display.short_description = 'Valid'
