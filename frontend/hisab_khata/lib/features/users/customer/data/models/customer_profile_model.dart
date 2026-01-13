import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';

/// Customer Profile Model
/// Handles JSON serialization/deserialization for customer profile data
class CustomerProfileModel extends CustomerProfileEntity {
  const CustomerProfileModel({
    required super.fullName,
    super.phoneNumber,
    super.profilePicture,
    required super.email,
    super.preferredLanguage,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      email: json['email'] ?? '',
      preferredLanguage: json['preferred_language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'email': email,
      'preferred_language': preferredLanguage,
    };
  }
}
