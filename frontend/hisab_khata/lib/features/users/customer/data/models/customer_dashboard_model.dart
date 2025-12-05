import 'package:hisab_khata/features/users/customer/domain/entities/customer_dashboard_entity.dart';

/// Customer Dashboard Model
/// Handles JSON serialization/deserialization for customer dashboard data
class CustomerDashboardModel extends CustomerDashboardEntity {
  const CustomerDashboardModel({
    required super.customerId,
    required super.fullName,
    super.profilePicture,
    required super.toGive,
    required super.toTake,
    required super.totalShops,
    required super.pendingRequests,
    required super.recentTransactions,
    required super.loyaltyPoints,
  });

  factory CustomerDashboardModel.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardModel(
      customerId: json['customer_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      profilePicture: json['profile_picture'],
      toGive: _parseDouble(json['to_give']),
      toTake: _parseDouble(json['to_take']),
      totalShops: json['total_shops'] ?? 0,
      pendingRequests: json['pending_requests'] ?? 0,
      recentTransactions: json['recent_transactions'] ?? [],
      loyaltyPoints: json['loyalty_points'] ?? 0,
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
      'customer_id': customerId,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'to_give': toGive,
      'to_take': toTake,
      'total_shops': totalShops,
      'pending_requests': pendingRequests,
      'recent_transactions': recentTransactions,
      'loyalty_points': loyaltyPoints,
    };
  }
}
