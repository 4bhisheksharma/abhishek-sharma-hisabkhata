import '../../domain/entities/connected_user.dart';

class ConnectedUserModel extends ConnectedUser {
  const ConnectedUserModel({
    required super.userId,
    required super.email,
    super.phoneNumber,
    required super.fullName,
    super.profilePicture,
    required super.isBusiness,
    super.businessId,
    super.businessName,
    super.customerId,
    required super.connectedAt,
    required super.requestId,
  });

  factory ConnectedUserModel.fromJson(Map<String, dynamic> json) {
    return ConnectedUserModel(
      userId: json['user_id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      isBusiness: json['is_business'] ?? false,
      businessId: json['business_id'],
      businessName: json['business_name'],
      customerId: json['customer_id'],
      connectedAt: DateTime.parse(json['connected_at']),
      requestId: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'is_business': isBusiness,
      'business_id': businessId,
      'business_name': businessName,
      'customer_id': customerId,
      'connected_at': connectedAt.toIso8601String(),
      'request_id': requestId,
    };
  }
}
