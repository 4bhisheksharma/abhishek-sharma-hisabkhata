from rest_framework import serializers
from .esewa_models import BusinessEsewaAccount, EsewaPaymentRecord


class BusinessEsewaAccountSerializer(serializers.ModelSerializer):
    """Serializer for business eSewa account details"""
    business_name = serializers.CharField(source='business.business_name', read_only=True)

    class Meta:
        model = BusinessEsewaAccount
        fields = [
            'id', 'esewa_id', 'account_name',
            'is_active', 'business_name', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'business_name', 'created_at', 'updated_at']


class CreateBusinessEsewaAccountSerializer(serializers.Serializer):
    """Serializer for creating/updating a business eSewa account"""
    esewa_id = serializers.CharField(max_length=20)
    account_name = serializers.CharField(max_length=255)

    def validate_esewa_id(self, value):
        """Validate eSewa ID format (should be a phone number)"""
        # Remove any spaces or dashes
        cleaned = value.replace(' ', '').replace('-', '')
        if not cleaned.startswith('98') and not cleaned.startswith('97'):
            if not cleaned.startswith('9'):
                raise serializers.ValidationError(
                    "eSewa ID should be a valid Nepali phone number starting with 9"
                )
        if len(cleaned) != 10:
            raise serializers.ValidationError(
                "eSewa ID should be a 10-digit phone number"
            )
        return cleaned


class InitiateEsewaPaymentSerializer(serializers.Serializer):
    """Serializer for initiating an eSewa payment"""
    relationship_id = serializers.IntegerField()
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    description = serializers.CharField(max_length=255, required=False, allow_blank=True)

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than 0")
        return value


class VerifyEsewaPaymentSerializer(serializers.Serializer):
    """Serializer for verifying an eSewa payment after success callback"""
    payment_record_id = serializers.IntegerField()
    esewa_ref_id = serializers.CharField(max_length=100)
    esewa_product_id = serializers.CharField(max_length=255)
    total_amount = serializers.CharField(max_length=50)
    status = serializers.CharField(max_length=20)
    esewa_response = serializers.DictField(required=False)


class EsewaPaymentRecordSerializer(serializers.ModelSerializer):
    """Serializer for eSewa payment records"""
    class Meta:
        model = EsewaPaymentRecord
        fields = [
            'id', 'relationship_id', 'amount', 'esewa_ref_id',
            'esewa_product_id', 'status', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class BusinessEsewaStatusSerializer(serializers.Serializer):
    """Serializer for checking if a business has eSewa linked"""
    has_esewa = serializers.BooleanField()
    esewa_id = serializers.CharField(allow_null=True, required=False)
    account_name = serializers.CharField(allow_null=True, required=False)
    is_active = serializers.BooleanField(default=False)
