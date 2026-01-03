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
from hisabauth.views import RegisterView, LoginView
from otp_verification.views import VerifyOTPView, ResendOTPView

urlpatterns = [
    path('admin/', admin.site.urls),
    # All API endpoints under 'api/'
    path('api/', include([
        # Auth endpoints
        path('auth/register/', RegisterView.as_view(), name='register'),
        path('auth/verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
        path('auth/resend-otp/', ResendOTPView.as_view(), name='resend-otp'),
        path('auth/login/', LoginView.as_view(), name='login'),
        
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
    ])),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)