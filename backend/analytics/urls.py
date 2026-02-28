from django.urls import path
from .views import (
    PaidVsToPayView, MonthlyTransactionTrendView, TotalTransactionsView,
    TotalAmountView, MonthlySpendingLimitView, AdminDashboardStatsAPI,
    AdminToggleBusinessVerifiedView, AdminToggleUserActiveView,
    AdminUserListView, AdminDeleteUserView, AdminUpdateTicketStatusView,
    AdminSendBroadcastView, AdminTicketDetailView,
    AdminVerificationRequestsView, AdminReviewVerificationView,
    admin_dashboard_view, admin_user_management_view,
    admin_all_businesses_view, admin_all_customers_view,
    admin_analytics_view, admin_communication_view,
)

app_name = 'analytics'

urlpatterns = [
    path('paid-vs-to-pay/', PaidVsToPayView.as_view(), name='paid_vs_to_pay'),
    path('monthly-transaction-trend/', MonthlyTransactionTrendView.as_view(), name='monthly_transaction_trend'),
    path('total-transactions/', TotalTransactionsView.as_view(), name='total_transactions'),
    path('total-amount/', TotalAmountView.as_view(), name='total_amount'),
    path('monthly-spending-limit/', MonthlySpendingLimitView.as_view(), name='monthly_spending_limit'),
    path('admin-stats/', AdminDashboardStatsAPI.as_view(), name='admin_dashboard_stats'),

    # Admin panel API endpoints
    path('admin/toggle-business-verified/<int:business_id>/', AdminToggleBusinessVerifiedView.as_view(), name='admin_toggle_business_verified'),
    path('admin/toggle-user-active/<int:user_id>/', AdminToggleUserActiveView.as_view(), name='admin_toggle_user_active'),
    path('admin/users/', AdminUserListView.as_view(), name='admin_user_list'),
    path('admin/delete-user/<int:user_id>/', AdminDeleteUserView.as_view(), name='admin_delete_user'),
    path('admin/update-ticket/<int:ticket_id>/', AdminUpdateTicketStatusView.as_view(), name='admin_update_ticket'),
    path('admin/ticket/<int:ticket_id>/', AdminTicketDetailView.as_view(), name='admin_ticket_detail'),
    path('admin/broadcast/', AdminSendBroadcastView.as_view(), name='admin_send_broadcast'),
    path('admin/verification-requests/', AdminVerificationRequestsView.as_view(), name='admin_verification_requests'),
    path('admin/verification-requests/<int:request_id>/review/', AdminReviewVerificationView.as_view(), name='admin_review_verification'),
]