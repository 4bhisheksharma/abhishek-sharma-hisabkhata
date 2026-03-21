from django.urls import path

from .views import (
    HybridAccountStatusView,
    HybridCitizenshipUploadView,
    HybridSwitchSubmitView,
    MyHybridSwitchRequestsView,
)

urlpatterns = [
    path('status/', HybridAccountStatusView.as_view(), name='hybrid-status'),
    path('upload-citizenship/', HybridCitizenshipUploadView.as_view(), name='hybrid-upload-citizenship'),
    path('submit/', HybridSwitchSubmitView.as_view(), name='hybrid-submit'),
    path('my-requests/', MyHybridSwitchRequestsView.as_view(), name='hybrid-my-requests'),
]
