import 'package:equatable/equatable.dart';
import 'transaction.dart';

class ConnectedUserDetails extends Equatable {
  final int userId;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePicture;
  
  // Business specific
  final bool isBusiness;
  final int? businessId;
  final String? businessName;
  
  // Customer specific
  final int? customerId;
  
  // Relationship info
  final int relationshipId;
  final DateTime connectedAt;
  
  // Financial summary
  final double toPay;
  final double totalPaid;
  
  // Favorite (only for customers viewing businesses)
  final bool isFavorite;
  
  // Transaction history
  final List<Transaction> transactions;

  const ConnectedUserDetails({
    required this.userId,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePicture,
    required this.isBusiness,
    this.businessId,
    this.businessName,
    this.customerId,
    required this.relationshipId,
    required this.connectedAt,
    required this.toPay,
    required this.totalPaid,
    this.isFavorite = false,
    this.transactions = const [],
  });

  /// Display name - business name for businesses, full name for customers
  String get displayName => isBusiness && businessName != null 
      ? businessName! 
      : fullName;

  /// Contact info - phone number or email
  String get contactInfo => phoneNumber ?? email;

  /// Total purchases (sum of debit transactions)
  double get totalPurchases {
    return transactions
        .where((t) => t.isDebit)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total payments (sum of credit transactions)
  double get totalPayments {
    return transactions
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Number of transactions
  int get transactionCount => transactions.length;

  /// Copy with updated favorite status
  ConnectedUserDetails copyWith({
    bool? isFavorite,
    List<Transaction>? transactions,
    double? toPay,
    double? totalPaid,
  }) {
    return ConnectedUserDetails(
      userId: userId,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      profilePicture: profilePicture,
      isBusiness: isBusiness,
      businessId: businessId,
      businessName: businessName,
      customerId: customerId,
      relationshipId: relationshipId,
      connectedAt: connectedAt,
      toPay: toPay ?? this.toPay,
      totalPaid: totalPaid ?? this.totalPaid,
      isFavorite: isFavorite ?? this.isFavorite,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        phoneNumber,
        fullName,
        profilePicture,
        isBusiness,
        businessId,
        businessName,
        customerId,
        relationshipId,
        connectedAt,
        toPay,
        totalPaid,
        isFavorite,
        transactions,
      ];
}
