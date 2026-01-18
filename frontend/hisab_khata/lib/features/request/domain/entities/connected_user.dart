import 'package:equatable/equatable.dart';

/// Entity representing a connected user with business/customer details
class ConnectedUser extends Equatable {
  final int userId;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePicture;
  final bool isBusiness;
  final int? businessId;
  final String? businessName;
  final int? customerId;
  final DateTime connectedAt;
  final int requestId;
  final int relationshipId;
  final double pendingDue;

  const ConnectedUser({
    required this.userId,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePicture,
    required this.isBusiness,
    this.businessId,
    this.businessName,
    this.customerId,
    required this.connectedAt,
    required this.requestId,
    required this.relationshipId,
    this.pendingDue = 0.0,
  });

  /// Returns display name - business name if business, otherwise full name
  String get displayName =>
      isBusiness && businessName != null ? businessName! : fullName;

  /// Returns contact info - phone if available, otherwise email
  String get contactInfo => phoneNumber ?? email;

  /// Returns true if user has pending dues
  bool get hasPendingDue => pendingDue != 0.0;

  @override
  List<Object?> get props => [
    userId,
    email,
    phoneNumber,
    fullName,
    profilePicture,
    isBusiness,
    businessId,
    businessName,
    customerId,
    connectedAt,
    requestId,
    relationshipId,
    pendingDue,
  ];
}
