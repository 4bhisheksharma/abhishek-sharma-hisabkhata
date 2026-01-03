from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TransactionViewSet, ConnectedUserDetailsViewSet, FavoriteViewSet

router = DefaultRouter()
router.register(r'transactions', TransactionViewSet, basename='transaction')
router.register(r'favorites', FavoriteViewSet, basename='favorite')
router.register(r'connection-details', ConnectedUserDetailsViewSet, basename='connection-details')

urlpatterns = [
    path('', include(router.urls)),
]
