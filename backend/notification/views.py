from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Notification
from .serializers import NotificationSerializer


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
            status=status.HTTP_204_NO_CONTENT
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

