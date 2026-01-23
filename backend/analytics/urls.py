from django.urls import path
from .views import PaidVsToPayView, MonthlyTransactionTrendView

app_name = 'analytics'

urlpatterns = [
    path('paid-vs-to-pay/', PaidVsToPayView.as_view(), name='paid_vs_to_pay'),
    path('monthly-transaction-trend/', MonthlyTransactionTrendView.as_view(), name='monthly_transaction_trend'),
]