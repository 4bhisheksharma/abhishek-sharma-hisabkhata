from django.urls import path
from .views import PaidVsToPayView

app_name = 'analytics'

urlpatterns = [
    path('paid-vs-to-pay/', PaidVsToPayView.as_view(), name='paid_vs_to_pay'),
]