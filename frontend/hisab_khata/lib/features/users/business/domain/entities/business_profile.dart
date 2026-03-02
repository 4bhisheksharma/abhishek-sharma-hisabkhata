class BusinessProfile {
  final String businessName;
  final String fullName;
  final String phoneNumber;
  final String? profilePicture;
  final String email;
  final bool isVerified;
  final String? preferredLanguage;
  final double? latitude;
  final double? longitude;
  final String? address;

  const BusinessProfile({
    required this.businessName,
    required this.fullName,
    required this.phoneNumber,
    this.profilePicture,
    required this.email,
    required this.isVerified,
    this.preferredLanguage,
    this.latitude,
    this.longitude,
    this.address,
  });
}
