import 'package:equatable/equatable.dart';

/// Customer Dashboard Entity
/// Represents the customer home dashboard overview data
class CustomerDashboardEntity extends Equatable {
  final int customerId;
  final String fullName;
  final String? profilePicture;
  final double toGive;
  final double toTake;
  final int totalShops;
  final int pendingRequests;
  final List<dynamic> recentTransactions;
  final int loyaltyPoints;

  const CustomerDashboardEntity({
    required this.customerId,
    required this.fullName,
    this.profilePicture,
    required this.toGive,
    required this.toTake,
    required this.totalShops,
    required this.pendingRequests,
    required this.recentTransactions,
    required this.loyaltyPoints,
  });

  @override
  List<Object?> get props => [
    customerId,
    fullName,
    profilePicture,
    toGive,
    toTake,
    totalShops,
    pendingRequests,
    recentTransactions,
    loyaltyPoints,
  ];
}
