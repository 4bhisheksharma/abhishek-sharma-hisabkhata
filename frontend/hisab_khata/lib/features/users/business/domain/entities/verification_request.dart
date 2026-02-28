class VerificationRequest {
  final int id;
  final String? businessName;
  final String? documentUrl;
  final String documentType;
  final String? note;
  final String status;
  final String? adminRemarks;
  final String? reviewedAt;
  final String createdAt;
  final String? updatedAt;

  const VerificationRequest({
    required this.id,
    this.businessName,
    this.documentUrl,
    required this.documentType,
    this.note,
    required this.status,
    this.adminRemarks,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class VerificationStatus {
  final bool isVerified;
  final bool hasPendingRequest;
  final VerificationRequest? latestRequest;

  const VerificationStatus({
    required this.isVerified,
    required this.hasPendingRequest,
    this.latestRequest,
  });
}
