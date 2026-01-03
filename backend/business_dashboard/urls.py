from django.urls import path
from .views import (
    BusinessDashboardView,
    BusinessProfileView,
    RecentCustomersView,
)

urlpatterns = [
    # Dashboard
    path('dashboard/', BusinessDashboardView.as_view(), name='business-dashboard'),
    
    # Profile - GET, PATCH
    path('profile/', BusinessProfileView.as_view(), name='business-profile'),
    
    # Recent Customers - GET (with optional ?limit=N query param)
    path('recent-customers/', RecentCustomersView.as_view(), name='business-recent-customers'),
]
