import '../../domain/entities/hybrid_switch_request_entity.dart';
import '../../domain/entities/hybrid_switch_status_entity.dart';

class HybridSwitchStatusModel extends HybridSwitchStatusEntity {
  const HybridSwitchStatusModel({
    required super.accountType,
    required super.isBusinessVerified,
    required super.canRequest,
    required super.hasPendingRequest,
  });

  factory HybridSwitchStatusModel.fromJson(Map<String, dynamic> json) {
    return HybridSwitchStatusModel(
      accountType: (json['account_type'] ?? '') as String,
      isBusinessVerified: (json['is_business_verified'] ?? false) as bool,
      canRequest: (json['can_request'] ?? false) as bool,
      hasPendingRequest: (json['has_pending_request'] ?? false) as bool,
    );
  }
}

class HybridSwitchRequestModel extends HybridSwitchRequestEntity {
  const HybridSwitchRequestModel({
    required super.id,
    required super.accountType,
    required super.isBusinessVerifiedAtRequest,
    required super.status,
    super.citizenshipDocumentUrl,
    super.adminRemarks,
    super.submittedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HybridSwitchRequestModel.fromJson(Map<String, dynamic> json) {
    return HybridSwitchRequestModel(
      id: (json['hybrid_request_id'] ?? 0) as int,
      accountType: (json['account_type'] ?? '') as String,
      isBusinessVerifiedAtRequest:
          (json['is_business_verified_at_request'] ?? false) as bool,
      status: (json['status'] ?? '') as String,
      citizenshipDocumentUrl:
          json['citizenship_document_url'] as String? ??
          json['citizenship_document'] as String?,
      adminRemarks: json['admin_remarks'] as String?,
      submittedAt: _parseDateTime(json['submitted_at']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
