from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import NotificationViewSet, BroadcastNotificationView, BulkPaymentReminderView

router = DefaultRouter()
router.register(r'', NotificationViewSet, basename='notification')

urlpatterns = [
    path('broadcast/', BroadcastNotificationView.as_view(), name='broadcast-notification'),
    path('bulk-payment-reminder/', BulkPaymentReminderView.as_view(), name='bulk-payment-reminder'),
    path('', include(router.urls)),
]
