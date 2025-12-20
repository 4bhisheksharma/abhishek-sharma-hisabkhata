from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ConnectionRequestViewSet

router = DefaultRouter()
router.register(r'connections', ConnectionRequestViewSet, basename='connection-request')

urlpatterns = [
    path('', include(router.urls)),
]
