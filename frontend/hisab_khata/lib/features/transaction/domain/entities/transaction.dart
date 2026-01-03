import 'package:equatable/equatable.dart';

enum TransactionType {
  purchase,
  payment,
  credit,
  refund,
  adjustment;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransactionType.purchase,
    );
  }
}

class Transaction extends Equatable {
  final int transactionId;
  final double amount;
  final TransactionType transactionType;
  final String description;
  final DateTime transactionDate;
  final DateTime createdAt;

  const Transaction({
    required this.transactionId,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.transactionDate,
    required this.createdAt,
  });

  /// Returns true if this transaction increases what customer owes (purchase/credit)
  bool get isDebit =>
      transactionType == TransactionType.purchase ||
      transactionType == TransactionType.credit;

  /// Returns true if this transaction decreases what customer owes (payment/refund)
  bool get isCredit =>
      transactionType == TransactionType.payment ||
      transactionType == TransactionType.refund;

  /// Formatted transaction type for display
  String get typeDisplay {
    switch (transactionType) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  @override
  List<Object?> get props => [
    transactionId,
    amount,
    transactionType,
    description,
    transactionDate,
    createdAt,
  ];
}
