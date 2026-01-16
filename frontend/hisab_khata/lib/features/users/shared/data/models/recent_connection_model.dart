import '../../domain/entities/recent_connection_entity.dart';

/// Model for recent connection data from API
/// Handles JSON serialization/deserialization
class RecentConnectionModel extends RecentConnectionEntity {
  const RecentConnectionModel({
    required super.id,
    required super.relationshipId,
    required super.name,
    super.profilePicture,
    super.contact,
    required super.email,
    required super.pendingDue,
    required super.addedAt,
  });

  /// Factory constructor for recent business (customer view)
  factory RecentConnectionModel.fromBusinessJson(Map<String, dynamic> json) {
    return RecentConnectionModel(
      id: json['business_id'] ?? 0,
      relationshipId: json['relationship_id'] ?? 0,
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      contact: json['contact'],
      email: json['email'] ?? '',
      pendingDue: _parseDouble(json['pending_due']),
      addedAt: _parseDateTime(json['added_at']),
    );
  }

  /// Factory constructor for recent customer (business view)
  factory RecentConnectionModel.fromCustomerJson(Map<String, dynamic> json) {
    return RecentConnectionModel(
      id: json['customer_id'] ?? 0,
      relationshipId: json['relationship_id'] ?? 0,
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      contact: json['contact'],
      email: json['email'] ?? '',
      pendingDue: _parseDouble(json['pending_due']),
      addedAt: _parseDateTime(json['added_at']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationship_id': relationshipId,
      'name': name,
      'profile_picture': profilePicture,
      'contact': contact,
      'email': email,
      'pending_due': pendingDue,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
