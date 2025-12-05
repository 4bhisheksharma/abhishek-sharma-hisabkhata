import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';

/// Customer Profile Model
/// Handles JSON serialization/deserialization for customer profile data
class CustomerProfileModel extends CustomerProfileEntity {
  const CustomerProfileModel({
    required super.fullName,
    super.phoneNumber,
    super.profilePicture,
    required super.email,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'email': email,
    };
  }
}
