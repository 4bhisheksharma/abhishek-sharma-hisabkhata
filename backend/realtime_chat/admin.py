from django.contrib import admin
from .models import ChatRoom, Message, MessageStatus


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = [
        'chat_room_id',
        'get_customer_name',
        'get_business_name',
        'created_at'
    ]
    search_fields = [
        'relationship__customer__user__full_name',
        'relationship__business__business_name'
    ]
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']
    
    def get_customer_name(self, obj):
        return obj.relationship.customer.user.full_name
    get_customer_name.short_description = 'Customer'
    
    def get_business_name(self, obj):
        return obj.relationship.business.business_name
    get_business_name.short_description = 'Business'


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = [
        'message_id',
        'chat_room',
        'sender',
        'message_type',
        'content_preview',
        'is_edited',
        'is_deleted',
        'created_at'
    ]
    list_filter = ['message_type', 'is_edited', 'is_deleted', 'created_at']
    search_fields = ['content', 'sender__full_name', 'sender__email']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']
    
    def content_preview(self, obj):
        return obj.content[:50] + '...' if len(obj.content) > 50 else obj.content
    content_preview.short_description = 'Content'


@admin.register(MessageStatus)
class MessageStatusAdmin(admin.ModelAdmin):
    list_display = [
        'message_status_id',
        'message',
        'user',
        'status',
        'timestamp'
    ]
    list_filter = ['status', 'timestamp']
    search_fields = ['user__full_name', 'user__email']
    readonly_fields = ['timestamp']
    ordering = ['-timestamp']
