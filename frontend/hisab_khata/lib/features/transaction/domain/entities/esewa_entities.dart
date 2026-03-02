import 'package:equatable/equatable.dart';

/// Represents a business's linked eSewa account
class BusinessEsewaAccount extends Equatable {
  final int id;
  final String esewaId;
  final String accountName;
  final bool isActive;
  final String? businessName;
  final DateTime? createdAt;

  const BusinessEsewaAccount({
    required this.id,
    required this.esewaId,
    required this.accountName,
    required this.isActive,
    this.businessName,
    this.createdAt,
  });

  factory BusinessEsewaAccount.fromJson(Map<String, dynamic> json) {
    return BusinessEsewaAccount(
      id: json['id'] as int,
      esewaId: json['esewa_id'] as String,
      accountName: json['account_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      businessName: json['business_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    esewaId,
    accountName,
    isActive,
    businessName,
    createdAt,
  ];
}

/// eSewa status for a business (from customer perspective)
class BusinessEsewaStatus extends Equatable {
  final bool hasEsewa;
  final String? esewaId;
  final String? accountName;
  final bool isActive;

  const BusinessEsewaStatus({
    required this.hasEsewa,
    this.esewaId,
    this.accountName,
    this.isActive = false,
  });

  factory BusinessEsewaStatus.fromJson(Map<String, dynamic> json) {
    return BusinessEsewaStatus(
      hasEsewa: json['has_esewa'] as bool? ?? false,
      esewaId: json['esewa_id'] as String?,
      accountName: json['account_name'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [hasEsewa, esewaId, accountName, isActive];
}

/// Payment initiation response from the backend
class EsewaPaymentInitiation extends Equatable {
  final int paymentRecordId;
  final String productId;
  final String productName;
  final String amount;
  final String businessEsewaId;

  const EsewaPaymentInitiation({
    required this.paymentRecordId,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.businessEsewaId,
  });

  factory EsewaPaymentInitiation.fromJson(Map<String, dynamic> json) {
    return EsewaPaymentInitiation(
      paymentRecordId: json['payment_record_id'] as int,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      amount: json['amount'] as String,
      businessEsewaId: json['business_esewa_id'] as String,
    );
  }

  @override
  List<Object?> get props => [
    paymentRecordId,
    productId,
    productName,
    amount,
    businessEsewaId,
  ];
}
