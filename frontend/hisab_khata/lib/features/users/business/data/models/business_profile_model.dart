import '../../domain/entities/business_profile.dart';

/// Business Profile Model
/// Handles JSON serialization/deserialization for business profile data
class BusinessProfileModel extends BusinessProfile {
  BusinessProfileModel({
    required super.businessName,
    required super.fullName,
    required super.phoneNumber,
    super.profilePicture,
    required super.email,
    required super.isVerified,
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      businessName: json['business_name'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      email: json['email'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'email': email,
      'is_verified': isVerified,
    };
  }
}
