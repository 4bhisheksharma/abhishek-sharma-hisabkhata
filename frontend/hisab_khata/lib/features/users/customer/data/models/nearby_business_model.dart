/// Model representing a nearby business on the map
class NearbyBusinessModel {
  final int businessId;
  final String businessName;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isVerified;
  final int userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final bool isConnected;
  final int? relationshipId;
  final String? connectionStatus; // 'connected', 'pending', or null

  const NearbyBusinessModel({
    required this.businessId,
    required this.businessName,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.isVerified,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.isConnected = false,
    this.relationshipId,
    this.connectionStatus,
  });

  factory NearbyBusinessModel.fromJson(Map<String, dynamic> json) {
    return NearbyBusinessModel(
      businessId: json['business_id'] ?? 0,
      businessName: json['business_name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      isConnected: json['is_connected'] ?? false,
      relationshipId: json['relationship_id'],
      connectionStatus: json['connection_status'],
    );
  }
}
