from django.conf import settings
from django.db import models


class HybridSwitchRequest(models.Model):
	"""Stores user requests to switch account mode to hybrid."""

	ACCOUNT_TYPE_CHOICES = [
		('business', 'Business'),
		('customer', 'Customer'),
	]

	STATUS_CHOICES = [
		('draft', 'Draft'),
		('pending', 'Pending'),
		('approved', 'Approved'),
		('rejected', 'Rejected'),
	]

	hybrid_request_id = models.AutoField(primary_key=True)
	user = models.ForeignKey(
		settings.AUTH_USER_MODEL,
		on_delete=models.CASCADE,
		related_name='hybrid_switch_requests',
	)
	account_type = models.CharField(max_length=20, choices=ACCOUNT_TYPE_CHOICES)
	is_business_verified_at_request = models.BooleanField(default=False)
	citizenship_document = models.ImageField(
		upload_to='verification_documents/hybrid_citizenship/'
	)
	status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
	admin_remarks = models.TextField(blank=True, null=True)
	submitted_at = models.DateTimeField(null=True, blank=True)
	reviewed_by = models.ForeignKey(
		settings.AUTH_USER_MODEL,
		on_delete=models.SET_NULL,
		null=True,
		blank=True,
		related_name='reviewed_hybrid_switch_requests',
	)
	reviewed_at = models.DateTimeField(null=True, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = 'hybrid_switch_request'
		ordering = ['-created_at']
		indexes = [
			models.Index(fields=['user', 'status']),
		]

	def __str__(self):
		return f'HybridSwitchRequest#{self.hybrid_request_id} {self.user.email} ({self.status})'
