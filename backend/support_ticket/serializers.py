from rest_framework import serializers
from .models import SupportTicket
from hisabauth.models import User


class SupportTicketSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.full_name', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    resolved_by_name = serializers.CharField(source='resolved_by.full_name', read_only=True)
    
    class Meta:
        model = SupportTicket
        fields = [
            'id',
            'user',
            'user_name',
            'user_email',
            'subject',
            'description',
            'category',
            'priority',
            'status',
            'admin_response',
            'resolved_by',
            'resolved_by_name',
            'resolved_at',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['user', 'resolved_by', 'resolved_at', 'created_at', 'updated_at']


class CreateSupportTicketSerializer(serializers.ModelSerializer):
    class Meta:
        model = SupportTicket
        fields = ['subject', 'description', 'category', 'priority']
    
    def create(self, validated_data):
        # User will be set from the request context
        user = self.context['request'].user
        validated_data['user'] = user
        return super().create(validated_data)


class UpdateTicketStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = SupportTicket
        fields = ['status', 'admin_response', 'priority']
    
    def update(self, instance, validated_data):
        from django.utils import timezone
        
        # If status is being changed to resolved or closed, set resolved_at
        new_status = validated_data.get('status', instance.status)
        if new_status in ['resolved', 'closed'] and instance.status not in ['resolved', 'closed']:
            instance.resolved_at = timezone.now()
            instance.resolved_by = self.context['request'].user
        
        return super().update(instance, validated_data)
