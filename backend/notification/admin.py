from django.contrib import admin
from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = [
        'notification_id',
        'title',
        'sender',
        'receiver',
        'type',
        'is_read',
        'created_at'
    ]
    list_filter = ['type', 'is_read', 'created_at']
    search_fields = ['title', 'message', 'sender__email', 'receiver__email']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']

