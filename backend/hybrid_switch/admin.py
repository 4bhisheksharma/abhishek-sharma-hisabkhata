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
