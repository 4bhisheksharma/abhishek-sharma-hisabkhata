from django.urls import path
from .views import (
    BusinessDashboardView,
    BusinessProfileView,
    RecentCustomersView,
    BusinessVerificationRequestView,
    BusinessVerificationStatusView,
    BusinessLocationUpdateView,
    NearbyBusinessesView,
)

urlpatterns = [
    # Dashboard
    path('dashboard/', BusinessDashboardView.as_view(), name='business-dashboard'),
    
    # Profile - GET, PATCH
    path('profile/', BusinessProfileView.as_view(), name='business-profile'),
    
    # Location - PATCH
    path('location/', BusinessLocationUpdateView.as_view(), name='business-location'),
    
    # Nearby Businesses - GET (for customers to see businesses on map)
    path('nearby/', NearbyBusinessesView.as_view(), name='nearby-businesses'),
    
    # Recent Customers - GET (with optional ?limit=N query param)
    path('recent-customers/', RecentCustomersView.as_view(), name='business-recent-customers'),

    # Verification - POST (submit request), GET (list requests)
    path('verification/request/', BusinessVerificationRequestView.as_view(), name='business-verification-request'),

    # Verification Status - GET
    path('verification/status/', BusinessVerificationStatusView.as_view(), name='business-verification-status'),
]
