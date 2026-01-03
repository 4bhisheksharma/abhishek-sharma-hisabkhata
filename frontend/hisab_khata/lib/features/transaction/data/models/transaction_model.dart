import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.transactionId,
    required super.amount,
    required super.transactionType,
    required super.description,
    required super.transactionDate,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] as int,
      amount: double.parse(json['amount'].toString()),
      transactionType: TransactionType.fromString(json['transaction_type'] as String),
      description: json['description'] as String? ?? '',
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'amount': amount.toString(),
      'transaction_type': transactionType.name,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert entity to model
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      transactionId: entity.transactionId,
      amount: entity.amount,
      transactionType: entity.transactionType,
      description: entity.description,
      transactionDate: entity.transactionDate,
      createdAt: entity.createdAt,
    );
  }
}
