from django.contrib import admin
from django.utils import timezone
from business_dashboard.models import Business, BusinessVerificationRequest
from notification.services import notify_verification_approved, notify_verification_rejected

import logging
logger = logging.getLogger(__name__)

@admin.register(Business)
class BusinessAdmin(admin.ModelAdmin):
    list_display = ['business_id', 'business_name', 'is_verified', 'created_at', 'updated_at']
    list_filter = ['is_verified', 'created_at']
    search_fields = ['business_name', 'user__email', 'user__full_name']
    readonly_fields = ['business_id', 'created_at', 'updated_at']
    
    # Allow admin to edit business verification status
    list_editable = ['is_verified']
    
    fieldsets = (
        ('Business Information', {
            'fields': ('business_id', 'business_name')
        }),
        ('Verification Status', {
            'fields': ('is_verified',),
            'description': 'Admin can verify or unverify businesses'
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )


@admin.register(BusinessVerificationRequest)
class BusinessVerificationRequestAdmin(admin.ModelAdmin):
    list_display = ['id', 'business_name', 'document_type', 'status', 'created_at', 'reviewed_at']
    list_filter = ['status', 'document_type', 'created_at']
    search_fields = ['business__business_name', 'business__user__email', 'document_type', 'note']
    readonly_fields = ['id', 'business', 'document', 'document_type', 'note', 'created_at', 'updated_at']
    list_per_page = 20
    ordering = ['-created_at']
    actions = ['approve_requests', 'reject_requests']

    fieldsets = (
        ('Request Details', {
            'fields': ('id', 'business', 'document', 'document_type', 'note')
        }),
        ('Review', {
            'fields': ('status', 'admin_remarks', 'reviewed_by', 'reviewed_at'),
            'description': 'Approve or reject the verification request after reviewing the document'
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )

    def business_name(self, obj):
        return obj.business.business_name
    business_name.short_description = 'Business Name'
    business_name.admin_order_field = 'business__business_name'

    def save_model(self, request, obj, form, change):
        """When admin changes status, auto-fill reviewed_by and reviewed_at, and update business verification."""
        if change and 'status' in form.changed_data:
            obj.reviewed_by = request.user
            obj.reviewed_at = timezone.now()
            if obj.status == 'approved':
                obj.business.is_verified = True
                obj.business.save()
                try:
                    notify_verification_approved(obj.business.user)
                except Exception as e:
                    logger.error(f"Verification approved notification error: {e}")
            elif obj.status == 'rejected':
                obj.business.is_verified = False
                obj.business.save()
                try:
                    notify_verification_rejected(obj.business.user, obj.admin_remarks or '')
                except Exception as e:
                    logger.error(f"Verification rejected notification error: {e}")
        super().save_model(request, obj, form, change)

    @admin.action(description='Approve selected verification requests')
    def approve_requests(self, request, queryset):
        count = 0
        for req in queryset.filter(status='pending'):
            req.status = 'approved'
            req.reviewed_by = request.user
            req.reviewed_at = timezone.now()
            req.admin_remarks = req.admin_remarks or 'Approved by admin'
            req.save()
            req.business.is_verified = True
            req.business.save()
            try:
                notify_verification_approved(req.business.user)
            except Exception as e:
                logger.error(f"Verification approved notification error: {e}")
            count += 1
        self.message_user(request, f'{count} request(s) approved successfully.')

    @admin.action(description='Reject selected verification requests')
    def reject_requests(self, request, queryset):
        count = 0
        for req in queryset.filter(status='pending'):
            req.status = 'rejected'
            req.reviewed_by = request.user
            req.reviewed_at = timezone.now()
            req.admin_remarks = req.admin_remarks or 'Rejected by admin'
            req.save()
            try:
                notify_verification_rejected(req.business.user, req.admin_remarks or '')
            except Exception as e:
                logger.error(f"Verification rejected notification error: {e}")
            count += 1
        self.message_user(request, f'{count} request(s) rejected.')