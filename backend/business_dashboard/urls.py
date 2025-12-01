from django.urls import path
from .views import (
    BusinessDashboardView,
    BusinessProfileView,
)

urlpatterns = [
    # Dashboard
    path('dashboard/', BusinessDashboardView.as_view(), name='business-dashboard'),
    
    # Profile - GET, PATCH
    path('profile/', BusinessProfileView.as_view(), name='business-profile'),
]
