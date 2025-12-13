import '../../domain/entities/business_dashboard.dart';

/// Business Dashboard Model
/// Handles JSON serialization/deserialization for business dashboard data
class BusinessDashboardModel extends BusinessDashboard {
  BusinessDashboardModel({
    required super.businessId,
    required super.businessName,
    super.profilePicture,
    required super.toGive,
    required super.toTake,
    required super.totalCustomers,
    required super.totalRequests,
  });

  factory BusinessDashboardModel.fromJson(Map<String, dynamic> json) {
    return BusinessDashboardModel(
      businessId: json['business_id'] ?? 0,
      businessName: json['business_name'] ?? '',
      profilePicture: json['profile_picture'],
      toGive: _parseDouble(json['to_give']),
      toTake: _parseDouble(json['to_take']),
      totalCustomers: json['total_customers'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'business_name': businessName,
      'profile_picture': profilePicture,
      'to_give': toGive,
      'to_take': toTake,
      'total_customers': totalCustomers,
      'total_requests': totalRequests,
    };
  }
}
