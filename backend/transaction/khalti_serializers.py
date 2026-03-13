from rest_framework import serializers
from .khalti_models import BusinessKhaltiAccount, KhaltiPaymentRecord


class BusinessKhaltiAccountSerializer(serializers.ModelSerializer):
    business_name = serializers.CharField(source="business.business_name", read_only=True)

    class Meta:
        model = BusinessKhaltiAccount
        fields = [
            "id",
            "khalti_id",
            "account_name",
            "is_active",
            "business_name",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "business_name", "created_at", "updated_at"]


class CreateBusinessKhaltiAccountSerializer(serializers.Serializer):
    khalti_id = serializers.CharField(max_length=20)
    account_name = serializers.CharField(max_length=255)

    def validate_khalti_id(self, value):
        cleaned = value.replace(" ", "").replace("-", "")
        if not cleaned.startswith("9"):
            raise serializers.ValidationError(
                "Khalti ID should be a valid Nepali phone number starting with 9"
            )
        if len(cleaned) != 10:
            raise serializers.ValidationError("Khalti ID should be a 10-digit phone number")
        return cleaned


class InitiateKhaltiPaymentSerializer(serializers.Serializer):
    relationship_id = serializers.IntegerField()
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    description = serializers.CharField(max_length=255, required=False, allow_blank=True)

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than 0")
        return value


class VerifyKhaltiPaymentSerializer(serializers.Serializer):
    payment_record_id = serializers.IntegerField()
    pidx = serializers.CharField(max_length=255)
    transaction_id = serializers.CharField(max_length=255, required=False, allow_blank=True)
    status = serializers.CharField(max_length=40, required=False, allow_blank=True)
    total_amount = serializers.CharField(max_length=50, required=False, allow_blank=True)
    khalti_response = serializers.DictField(required=False)


class KhaltiPaymentRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = KhaltiPaymentRecord
        fields = [
            "id",
            "relationship_id",
            "amount",
            "pidx",
            "khalti_transaction_id",
            "purchase_order_id",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]


class BusinessKhaltiStatusSerializer(serializers.Serializer):
    has_khalti = serializers.BooleanField()
    khalti_id = serializers.CharField(allow_null=True, required=False)
    account_name = serializers.CharField(allow_null=True, required=False)
    is_active = serializers.BooleanField(default=False)
