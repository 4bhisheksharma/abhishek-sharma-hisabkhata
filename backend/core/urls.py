"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from hisabauth.views import RegisterView, LoginView, ChangePasswordView, FCMTokenView, FCMTestView, LogoutView
from otp_verification.views import VerifyOTPView, ResendOTPView
from analytics.views import (
    admin_dashboard_view, admin_user_management_view,
    admin_all_businesses_view, admin_all_customers_view,
    admin_analytics_view, admin_communication_view,
    admin_logout_view, admin_index_redirect,
    admin_customers_view, admin_role_management_view,
    admin_support_tickets_view, admin_fraud_detection_view,
)

urlpatterns = [
    # Custom Admin Dashboard (must be before admin/)
    path('admin/dashboard/', admin_dashboard_view, name='admin_dashboard'),
    path('admin/dashboard/users/', admin_user_management_view, name='admin_user_management'),
    path('admin/dashboard/businesses/', admin_all_businesses_view, name='admin_all_businesses'),
    path('admin/dashboard/customers/', admin_all_customers_view, name='admin_all_customers'),
    path('admin/dashboard/customers-mgmt/', admin_customers_view, name='admin_customers'),
    path('admin/dashboard/roles/', admin_role_management_view, name='admin_roles'),
    path('admin/dashboard/tickets/', admin_support_tickets_view, name='admin_support_tickets'),
    path('admin/dashboard/analytics/', admin_analytics_view, name='admin_analytics'),
    path('admin/dashboard/fraud-detection/', admin_fraud_detection_view, name='admin_fraud_detection'),
    path('admin/dashboard/communication/', admin_communication_view, name='admin_communication'),
    path('admin/dashboard/logout/', admin_logout_view, name='admin_logout'),
    path('admin/', admin.site.urls),
    # All API endpoints under 'api/'
    path('api/', include([
        # Auth endpoints
        path('auth/register/', RegisterView.as_view(), name='register'),
        path('auth/verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
        path('auth/resend-otp/', ResendOTPView.as_view(), name='resend-otp'),
        path('auth/login/', LoginView.as_view(), name='login'),
        path('auth/logout/', LogoutView.as_view(), name='logout'),
        path('auth/change-password/', ChangePasswordView.as_view(), name='change-password'),
        path('auth/fcm-token/', FCMTokenView.as_view(), name='fcm-token'),
        path('auth/fcm-test/', FCMTestView.as_view(), name='fcm-test'),
        
        # Customer Dashboard
        path('customer/', include('customer_dashboard.urls')),
        
        # Business Dashboard
        path('business/', include('business_dashboard.urls')),
        
        # Connection Requests
        path('request/', include('request.urls')),
        
        # Notifications
        path('notifications/', include('notification.urls')),
        
        # Transactions & Favorites
        path('transaction/', include('transaction.urls')),
        
        # Support Tickets
        path('support/', include('support_ticket.urls')),
        
        # Analytics
        path('analytics/', include('analytics.urls')),
        
        # Real-time Chat
        path('chat/', include('realtime_chat.urls')),

        # Hybrid Switch Requests
        path('hybrid-switch/', include('hybrid_switch.urls')),
    ])),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)