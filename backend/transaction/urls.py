from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TransactionViewSet, ConnectedUserDetailsViewSet, FavoriteViewSet, TransactionActivityView
from .esewa_views import (
    BusinessEsewaAccountView,
    CheckBusinessEsewaStatusView,
    InitiateEsewaPaymentView,
    VerifyEsewaPaymentView,
)
from .khalti_views import (
    BusinessKhaltiAccountView,
    CheckBusinessKhaltiStatusView,
    InitiateKhaltiPaymentView,
    VerifyKhaltiPaymentView,
)

router = DefaultRouter()
router.register(r'transactions', TransactionViewSet, basename='transaction')
router.register(r'favorites', FavoriteViewSet, basename='favorite')
router.register(r'connection-details', ConnectedUserDetailsViewSet, basename='connection-details')

urlpatterns = [
    path('', include(router.urls)),

    # Transaction Activity (for profile screen)
    path('activity/', TransactionActivityView.as_view(), name='transaction-activity'),

    # eSewa endpoints
    path('esewa/account/', BusinessEsewaAccountView.as_view(), name='esewa-account'),
    path('esewa/status/<int:relationship_id>/', CheckBusinessEsewaStatusView.as_view(), name='esewa-status'),
    path('esewa/initiate/', InitiateEsewaPaymentView.as_view(), name='esewa-initiate'),
    path('esewa/verify/', VerifyEsewaPaymentView.as_view(), name='esewa-verify'),

    # Khalti endpoints
    path('khalti/account/', BusinessKhaltiAccountView.as_view(), name='khalti-account'),
    path('khalti/status/<int:relationship_id>/', CheckBusinessKhaltiStatusView.as_view(), name='khalti-status'),
    path('khalti/initiate/', InitiateKhaltiPaymentView.as_view(), name='khalti-initiate'),
    path('khalti/verify/', VerifyKhaltiPaymentView.as_view(), name='khalti-verify'),
]
