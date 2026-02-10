from django.contrib import admin
from .models import ChatRoom, Message


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ['chat_room_id', 'participant_one', 'participant_two', 'last_message_at', 'created_at']
    list_filter = ['created_at', 'last_message_at']
    search_fields = ['participant_one__full_name', 'participant_two__full_name', 'participant_one__email', 'participant_two__email']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['message_id', 'chat_room', 'sender', 'content_preview', 'message_type', 'is_read', 'created_at']
    list_filter = ['message_type', 'is_read', 'created_at']
    search_fields = ['content', 'sender__full_name', 'sender__email']
    readonly_fields = ['created_at', 'updated_at', 'read_at']
    
    def content_preview(self, obj):
        return obj.content[:50] + '...' if len(obj.content) > 50 else obj.content
    content_preview.short_description = 'Content'
