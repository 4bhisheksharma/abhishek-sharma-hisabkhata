from django.contrib import admin
from .models import Notification, NotificationType


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = [
        'notification_id',
        'title',
        'sender_display',
        'receiver',
        'type',
        'is_read',
        'created_at'
    ]
    list_filter = ['type', 'is_read', 'created_at']
    search_fields = ['title', 'message', 'sender__email', 'receiver__email']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']
    list_per_page = 30

    def sender_display(self, obj):
        return obj.sender.email if obj.sender else 'System'
    sender_display.short_description = 'Sender'
    sender_display.admin_order_field = 'sender__email'

