import 'package:equatable/equatable.dart';

/// Entity representing a recent connection (business or customer)
/// Used for both "Recently Added Businesses" (customer view) 
/// and "Recently Added Customers" (business view)
class RecentConnectionEntity extends Equatable {
  final int id; // customer_id or business_id
  final String name;
  final String? profilePicture;
  final String? contact; // phone number if available
  final String email;
  final double pendingDue;
  final DateTime addedAt;

  const RecentConnectionEntity({
    required this.id,
    required this.name,
    this.profilePicture,
    this.contact,
    required this.email,
    required this.pendingDue,
    required this.addedAt,
  });

  /// Returns the contact info - phone if available, otherwise email
  String get contactInfo => contact ?? email;

  /// Returns formatted pending due with sign
  String get formattedPendingDue {
    if (pendingDue == 0) return 'Rs. 0';
    final sign = pendingDue > 0 ? '+' : '';
    return '$sign Rs. ${pendingDue.abs().toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        profilePicture,
        contact,
        email,
        pendingDue,
        addedAt,
      ];
}
