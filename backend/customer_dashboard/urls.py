from django.urls import path
from .views import (
    CustomerDashboardView,
    CustomerProfileView,
    RecentBusinessesView,
    MonthlySpendingOverviewView,
    MonthlyLimitView,
    FavoriteBusinessView,
)

app_name = 'customer_dashboard'

urlpatterns = [
    # Dashboard
    path('dashboard/', CustomerDashboardView.as_view(), name='customer-dashboard'),
    
    # Profile - GET, PATCH
    path('profile/', CustomerProfileView.as_view(), name='customer-profile'),
    
    # Recent Businesses - GET (with optional ?limit=N query param)
    path('recent-businesses/', RecentBusinessesView.as_view(), name='customer-recent-businesses'),
    
    # Monthly Spending Overview - Customer only
    path('monthly-spending-overview/', MonthlySpendingOverviewView.as_view(), name='monthly-spending-overview'),
    
    # Monthly Limit - Customer only (GET to retrieve, POST to set)
    path('monthly-limit/', MonthlyLimitView.as_view(), name='monthly-limit'),
    
    # Favorite Business - Customer only (PATCH to toggle favorite status)
    path('favorite-business/<int:business_id>/', FavoriteBusinessView.as_view(), name='favorite-business'),
]
