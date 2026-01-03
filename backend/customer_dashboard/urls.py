from django.urls import path
from .views import (
    CustomerDashboardView,
    CustomerProfileView,
    RecentBusinessesView,
)

urlpatterns = [
    # Dashboard
    path('dashboard/', CustomerDashboardView.as_view(), name='customer-dashboard'),
    
    # Profile - GET, PATCH
    path('profile/', CustomerProfileView.as_view(), name='customer-profile'),
    
    # Recent Businesses - GET (with optional ?limit=N query param)
    path('recent-businesses/', RecentBusinessesView.as_view(), name='customer-recent-businesses'),
]
