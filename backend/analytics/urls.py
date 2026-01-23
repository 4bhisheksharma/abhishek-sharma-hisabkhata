from django.urls import path
from .views import PaidVsToPayView, MonthlyTransactionTrendView, FavoriteCustomersView, FavoriteBusinessesView

app_name = 'analytics'

urlpatterns = [
    path('paid-vs-to-pay/', PaidVsToPayView.as_view(), name='paid_vs_to_pay'),
    path('monthly-transaction-trend/', MonthlyTransactionTrendView.as_view(), name='monthly_transaction_trend'),
    path('favorite-customers/', FavoriteCustomersView.as_view(), name='favorite_customers'),
    path('favorite-businesses/', FavoriteBusinessesView.as_view(), name='favorite_businesses'),
]