import '../../domain/entities/verification_request.dart';

class VerificationRequestModel extends VerificationRequest {
  VerificationRequestModel({
    required super.id,
    super.businessName,
    super.documentUrl,
    required super.documentType,
    super.note,
    required super.status,
    super.adminRemarks,
    super.reviewedAt,
    required super.createdAt,
    super.updatedAt,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] ?? 0,
      businessName: json['business_name'],
      documentUrl: json['document_url'],
      documentType: json['document_type'] ?? 'business_registration',
      note: json['note'],
      status: json['status'] ?? 'pending',
      adminRemarks: json['admin_remarks'],
      reviewedAt: json['reviewed_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }
}

class VerificationStatusModel extends VerificationStatus {
  VerificationStatusModel({
    required super.isVerified,
    required super.hasPendingRequest,
    super.verifiedAt,
    super.latestRequest,
  });

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VerificationStatusModel(
      isVerified: json['is_verified'] ?? false,
      hasPendingRequest: json['has_pending_request'] ?? false,
      verifiedAt: json['verified_at'],
      latestRequest: json['latest_request'] != null
          ? VerificationRequestModel.fromJson(json['latest_request'])
          : null,
    );
  }
}
