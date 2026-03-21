import 'package:equatable/equatable.dart';

class HybridSwitchRequestEntity extends Equatable {
  final int id;
  final String accountType;
  final bool isBusinessVerifiedAtRequest;
  final String status;
  final String? citizenshipDocumentUrl;
  final String? adminRemarks;
  final DateTime? submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HybridSwitchRequestEntity({
    required this.id,
    required this.accountType,
    required this.isBusinessVerifiedAtRequest,
    required this.status,
    this.citizenshipDocumentUrl,
    this.adminRemarks,
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isDraft => status == 'draft';

  @override
  List<Object?> get props => [
    id,
    accountType,
    isBusinessVerifiedAtRequest,
    status,
    citizenshipDocumentUrl,
    adminRemarks,
    submittedAt,
    createdAt,
    updatedAt,
  ];
}
