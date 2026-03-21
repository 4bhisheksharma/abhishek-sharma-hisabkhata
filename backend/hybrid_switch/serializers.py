from rest_framework import serializers

from .models import HybridSwitchRequest


class HybridSwitchRequestSerializer(serializers.ModelSerializer):
    citizenship_document_url = serializers.SerializerMethodField()

    class Meta:
        model = HybridSwitchRequest
        fields = [
            'hybrid_request_id',
            'account_type',
            'is_business_verified_at_request',
            'status',
            'citizenship_document',
            'citizenship_document_url',
            'admin_remarks',
            'submitted_at',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'hybrid_request_id',
            'account_type',
            'is_business_verified_at_request',
            'status',
            'admin_remarks',
            'submitted_at',
            'created_at',
            'updated_at',
            'citizenship_document_url',
        ]

    def get_citizenship_document_url(self, obj):
        request = self.context.get('request')
        if not obj.citizenship_document:
            return None
        if request:
            return request.build_absolute_uri(obj.citizenship_document.url)
        return obj.citizenship_document.url


class HybridSwitchUploadSerializer(serializers.Serializer):
    citizenship_document = serializers.ImageField(required=True)


class HybridSwitchSubmitSerializer(serializers.Serializer):
    hybrid_request_id = serializers.IntegerField(required=False)
