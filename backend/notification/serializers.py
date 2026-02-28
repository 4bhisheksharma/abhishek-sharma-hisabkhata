from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    sender_email = serializers.SerializerMethodField()
    sender_name = serializers.SerializerMethodField()
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
            'data',
            'is_read',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['notification_id', 'created_at', 'updated_at']

    def get_sender_email(self, obj):
        """Return sender email or 'system' for system notifications."""
        return obj.sender.email if obj.sender else 'system'

    def get_sender_name(self, obj):
        """Return sender name or 'Hisab Khata' for system notifications."""
        return obj.sender.full_name if obj.sender else 'Hisab Khata'
