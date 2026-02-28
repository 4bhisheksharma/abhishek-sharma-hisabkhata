from django.urls import path
from .views import (
    BusinessDashboardView,
    BusinessProfileView,
    RecentCustomersView,
    BusinessVerificationRequestView,
    BusinessVerificationStatusView,
)

urlpatterns = [
    # Dashboard
    path('dashboard/', BusinessDashboardView.as_view(), name='business-dashboard'),
    
    # Profile - GET, PATCH
    path('profile/', BusinessProfileView.as_view(), name='business-profile'),
    
    # Recent Customers - GET (with optional ?limit=N query param)
    path('recent-customers/', RecentCustomersView.as_view(), name='business-recent-customers'),

    # Verification - POST (submit request), GET (list requests)
    path('verification/request/', BusinessVerificationRequestView.as_view(), name='business-verification-request'),

    # Verification Status - GET
    path('verification/status/', BusinessVerificationStatusView.as_view(), name='business-verification-status'),
]
