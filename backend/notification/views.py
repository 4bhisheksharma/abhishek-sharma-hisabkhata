from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.views import APIView
from .models import Notification
from .serializers import NotificationSerializer
from .services import notify_broadcast, notify_bulk_payment_reminder

import logging
logger = logging.getLogger(__name__)


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for managing notifications
    """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Get notifications for the authenticated user"""
        return Notification.objects.filter(receiver=self.request.user)
    
    @action(detail=False, methods=['get'], url_path='unread')
    def unread_notifications(self, request):
        """Get all unread notifications"""
        notifications = self.get_queryset().filter(is_read=False)
        serializer = self.get_serializer(notifications, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='unread-count')
    def unread_count(self, request):
        """Get count of unread notifications"""
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'unread_count': count}, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['patch'], url_path='mark-read')
    def mark_as_read(self, request, pk=None):
        """Mark a specific notification as read"""
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        
        serializer = self.get_serializer(notification)
        return Response(
            {
                'message': 'Notification marked as read',
                'notification': serializer.data
            },
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['patch'], url_path='mark-all-read')
    def mark_all_as_read(self, request):
        """Mark all notifications as read for the authenticated user"""
        updated_count = self.get_queryset().filter(is_read=False).update(is_read=True)
        
        return Response(
            {
                'message': f'{updated_count} notification(s) marked as read',
                'updated_count': updated_count
            },
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_notification(self, request, pk=None):
        """Delete a specific notification"""
        notification = self.get_object()
        notification.delete()
        
        return Response(
            {'message': 'Notification deleted successfully'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['delete'], url_path='delete-all-read')
    def delete_all_read(self, request):
        """Delete all read notifications"""
        deleted_count, _ = self.get_queryset().filter(is_read=True).delete()
        
        return Response(
            {
                'message': f'{deleted_count} read notification(s) deleted',
                'deleted_count': deleted_count
            },
            status=status.HTTP_200_OK
        )


class BroadcastNotificationView(APIView):
    """
    Send a broadcast notification to ALL active users.
    Restricted to admin/staff users only.
    
    POST /api/notifications/broadcast/
    Body: { "title": "...", "message": "..." }
    """
    permission_classes = [IsAdminUser]

    def post(self, request):
        title = request.data.get('title', '').strip()
        message = request.data.get('message', '').strip()

        if not title or not message:
            return Response(
                {'error': 'Both title and message are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            count = notify_broadcast(
                title=title,
                message=message,
                sender_user=request.user,
            )
            return Response(
                {
                    'message': f'Broadcast sent to {count} user(s).',
                    'count': count,
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception as e:
            logger.error(f"Broadcast notification error: {e}")
            return Response(
                {'error': 'Failed to send broadcast.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class BulkPaymentReminderView(APIView):
    """
    Smart Payment Reminder — business sends bulk due reminders to all
    overdue customers at once.
    
    POST /api/notifications/bulk-payment-reminder/
    Body: { "min_amount": 100 }  (optional, default 0.01)
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from customer_dashboard.models import CustomerBusinessRelationship
        from decimal import Decimal

        user = request.user
        if not hasattr(user, 'business_profile'):
            return Response(
                {'error': 'Only business accounts can send bulk payment reminders.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        min_amount = Decimal(str(request.data.get('min_amount', '0.01')))
        business = user.business_profile

        overdue = CustomerBusinessRelationship.objects.filter(
            business=business,
            pending_due__gte=min_amount,
            status='active',
        ).select_related('customer__user')

        if not overdue.exists():
            return Response(
                {'message': 'No overdue customers found.', 'count': 0},
                status=status.HTTP_200_OK,
            )

        try:
            count = notify_bulk_payment_reminder(
                business_user=user,
                overdue_relationships=overdue,
            )
            return Response(
                {
                    'message': f'Payment reminder sent to {count} customer(s).',
                    'count': count,
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception as e:
            logger.error(f"Bulk payment reminder error: {e}")
            return Response(
                {'error': 'Failed to send bulk reminders.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
