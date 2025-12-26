from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    sender_email = serializers.EmailField(source='sender.email', read_only=True)
    sender_name = serializers.CharField(source='sender.full_name', read_only=True)
    receiver_email = serializers.EmailField(source='receiver.email', read_only=True)
    receiver_name = serializers.CharField(source='receiver.full_name', read_only=True)
    
    class Meta:
        model = Notification
        fields = [
            'notification_id',
            'sender',
            'sender_email',
            'sender_name',
            'receiver',
            'receiver_email',
            'receiver_name',
            'title',
            'message',
            'type',
            'is_read',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['notification_id', 'created_at', 'updated_at']
