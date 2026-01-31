from django.contrib import admin
from .models import ChatRoom, Message, MessageStatus


class MessageStatusInline(admin.TabularInline):
    """Inline admin for message statuses"""
    model = MessageStatus
    extra = 0
    readonly_fields = ['timestamp']
    fields = ['user', 'status', 'timestamp']


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    """Admin interface for ChatRoom model"""
    list_display = ['chat_room_id', 'get_customer_name', 'get_business_name', 'created_at', 'updated_at']
    list_filter = ['created_at', 'updated_at']
    search_fields = [
        'relationship__customer__user__full_name',
        'relationship__business__business_name',
        'relationship__customer__user__email',
        'relationship__business__user__email'
    ]
    readonly_fields = ['chat_room_id', 'created_at', 'updated_at']
    date_hierarchy = 'created_at'
    
    def get_customer_name(self, obj):
        return obj.relationship.customer.user.full_name
    get_customer_name.short_description = 'Customer'
    get_customer_name.admin_order_field = 'relationship__customer__user__full_name'
    
    def get_business_name(self, obj):
        return obj.relationship.business.business_name
    get_business_name.short_description = 'Business'
    get_business_name.admin_order_field = 'relationship__business__business_name'


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    """Admin interface for Message model"""
    list_display = [
        'message_id', 'chat_room', 'sender', 'message_type', 
        'get_content_preview', 'is_edited', 'is_deleted', 'created_at'
    ]
    list_filter = ['message_type', 'is_edited', 'is_deleted', 'created_at']
    search_fields = [
        'content', 
        'sender__full_name', 
        'sender__email',
        'chat_room__relationship__customer__user__full_name',
        'chat_room__relationship__business__business_name'
    ]
    readonly_fields = ['message_id', 'created_at', 'updated_at']
    date_hierarchy = 'created_at'
    inlines = [MessageStatusInline]
    
    fieldsets = (
        ('Message Info', {
            'fields': ('message_id', 'chat_room', 'sender', 'message_type')
        }),
        ('Content', {
            'fields': ('content', 'file_url')
        }),
        ('Status', {
            'fields': ('is_edited', 'is_deleted')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def get_content_preview(self, obj):
        """Show first 50 characters of content"""
        if len(obj.content) > 50:
            return f"{obj.content[:50]}..."
        return obj.content
    get_content_preview.short_description = 'Content Preview'


@admin.register(MessageStatus)
class MessageStatusAdmin(admin.ModelAdmin):
    """Admin interface for MessageStatus model"""
    list_display = ['message_status_id', 'message', 'user', 'status', 'timestamp']
    list_filter = ['status', 'timestamp']
    search_fields = [
        'user__full_name',
        'user__email',
        'message__content'
    ]
    readonly_fields = ['message_status_id', 'timestamp']
    date_hierarchy = 'timestamp'
    
    fieldsets = (
        ('Status Info', {
            'fields': ('message_status_id', 'message', 'user', 'status')
        }),
        ('Timestamp', {
            'fields': ('timestamp',)
        }),
    )

