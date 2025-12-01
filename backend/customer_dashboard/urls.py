from django.urls import path
from .views import (
    CustomerDashboardView,
    CustomerProfileView,
)

urlpatterns = [
    # Dashboard
    path('dashboard/', CustomerDashboardView.as_view(), name='customer-dashboard'),
    
    # Profile - GET, PUT, PATCH
    path('profile/', CustomerProfileView.as_view(), name='customer-profile'),

]
