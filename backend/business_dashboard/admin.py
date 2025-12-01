from django.contrib import admin
from business_dashboard.models import Business

@admin.register(Business)
class BusinessAdmin(admin.ModelAdmin):
    list_display = ['business_id', 'business_name', 'user', 'is_verified', 'created_at', "updated_at"]
     # admin can edit the business verification status to true or false
    list_filter = ['is_verified']

    search_fields = ['business_name', 'user__phone_number', 'user__full_name']