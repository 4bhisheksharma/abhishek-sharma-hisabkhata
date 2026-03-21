from django.contrib import admin

from .models import HybridSwitchRequest


@admin.register(HybridSwitchRequest)
class HybridSwitchRequestAdmin(admin.ModelAdmin):
	list_display = [
		'hybrid_request_id',
		'user',
		'account_type',
		'status',
		'is_business_verified_at_request',
		'submitted_at',
		'created_at',
	]
	list_filter = [
		'account_type',
		'status',
		'is_business_verified_at_request',
		'created_at',
	]
	search_fields = ['user__email', 'user__full_name']
	readonly_fields = ['created_at', 'updated_at', 'submitted_at', 'reviewed_at']
	ordering = ['-created_at']

	def get_readonly_fields(self, request, obj=None):
		readonly = list(super().get_readonly_fields(request, obj))
		if obj and obj.status in HybridSwitchRequest.FINAL_STATUSES:
			readonly.extend(['status', 'admin_remarks', 'reviewed_by'])
		return readonly
