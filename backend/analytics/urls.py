from django.urls import path
from .views import PaidVsToPayView, MonthlyTransactionTrendView, TotalTransactionsView, TotalAmountView, MonthlySpendingLimitView

app_name = 'analytics'

urlpatterns = [
    path('paid-vs-to-pay/', PaidVsToPayView.as_view(), name='paid_vs_to_pay'),
    path('monthly-transaction-trend/', MonthlyTransactionTrendView.as_view(), name='monthly_transaction_trend'),
    path('total-transactions/', TotalTransactionsView.as_view(), name='total_transactions'),
    path('total-amount/', TotalAmountView.as_view(), name='total_amount'),
    path('monthly-spending-limit/', MonthlySpendingLimitView.as_view(), name='monthly_spending_limit'),
]