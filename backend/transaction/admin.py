from django.contrib import admin
from .models import Transaction, Favorite
from .esewa_models import BusinessEsewaAccount, EsewaPaymentRecord
from .khalti_models import BusinessKhaltiAccount, KhaltiPaymentRecord


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ['transaction_id', 'relationship', 'amount', 'transaction_type', 'transaction_date']
    list_filter = ['transaction_type']
    search_fields = ['description']


@admin.register(Favorite)
class FavoriteAdmin(admin.ModelAdmin):
    list_display = ['favorite_id', 'customer', 'business', 'created_at']


@admin.register(BusinessEsewaAccount)
class BusinessEsewaAccountAdmin(admin.ModelAdmin):
    list_display = ['id', 'business', 'esewa_id', 'account_name', 'is_active', 'created_at']
    list_filter = ['is_active']
    search_fields = ['esewa_id', 'account_name', 'business__business_name']


@admin.register(EsewaPaymentRecord)
class EsewaPaymentRecordAdmin(admin.ModelAdmin):
    list_display = ['id', 'relationship', 'amount', 'esewa_ref_id', 'status', 'created_at']
    list_filter = ['status']
    search_fields = ['esewa_ref_id', 'esewa_product_id']


@admin.register(BusinessKhaltiAccount)
class BusinessKhaltiAccountAdmin(admin.ModelAdmin):
    list_display = ['id', 'business', 'khalti_id', 'account_name', 'is_active', 'created_at']
    list_filter = ['is_active']
    search_fields = ['khalti_id', 'account_name', 'business__business_name']


@admin.register(KhaltiPaymentRecord)
class KhaltiPaymentRecordAdmin(admin.ModelAdmin):
    list_display = ['id', 'relationship', 'amount', 'pidx', 'khalti_transaction_id', 'status', 'created_at']
    list_filter = ['status']
    search_fields = ['pidx', 'khalti_transaction_id', 'purchase_order_id']
