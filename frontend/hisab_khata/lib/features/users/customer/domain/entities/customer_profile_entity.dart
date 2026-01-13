import 'package:equatable/equatable.dart';

/// Customer Profile Entity
/// Represents the customer profile data
class CustomerProfileEntity extends Equatable {
  final String fullName;
  final String? phoneNumber;
  final String? profilePicture;
  final String email;
  final String? preferredLanguage;

  const CustomerProfileEntity({
    required this.fullName,
    this.phoneNumber,
    this.profilePicture,
    required this.email,
    this.preferredLanguage,
  });

  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    profilePicture,
    email,
    preferredLanguage,
  ];
}
