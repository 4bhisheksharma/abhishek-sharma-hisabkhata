import 'package:equatable/equatable.dart';

/// Represents a business's linked Khalti account
class BusinessKhaltiAccount extends Equatable {
  final int id;
  final String khaltiId;
  final String accountName;
  final bool isActive;
  final String? businessName;
  final DateTime? createdAt;

  const BusinessKhaltiAccount({
    required this.id,
    required this.khaltiId,
    required this.accountName,
    required this.isActive,
    this.businessName,
    this.createdAt,
  });

  factory BusinessKhaltiAccount.fromJson(Map<String, dynamic> json) {
    return BusinessKhaltiAccount(
      id: json['id'] as int,
      khaltiId: json['khalti_id'] as String,
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
    khaltiId,
    accountName,
    isActive,
    businessName,
    createdAt,
  ];
}

/// Khalti status for a business (from customer perspective)
class BusinessKhaltiStatus extends Equatable {
  final bool hasKhalti;
  final String? khaltiId;
  final String? accountName;
  final bool isActive;

  const BusinessKhaltiStatus({
    required this.hasKhalti,
    this.khaltiId,
    this.accountName,
    this.isActive = false,
  });

  factory BusinessKhaltiStatus.fromJson(Map<String, dynamic> json) {
    return BusinessKhaltiStatus(
      hasKhalti: json['has_khalti'] as bool? ?? false,
      khaltiId: json['khalti_id'] as String?,
      accountName: json['account_name'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [hasKhalti, khaltiId, accountName, isActive];
}

/// Khalti payment initiation response from backend
class KhaltiPaymentInitiation extends Equatable {
  final int paymentRecordId;
  final String pidx;
  final String? publicKey;
  final String environment;
  final String amount;
  final String purchaseOrderId;
  final String purchaseOrderName;

  const KhaltiPaymentInitiation({
    required this.paymentRecordId,
    required this.pidx,
    this.publicKey,
    required this.environment,
    required this.amount,
    required this.purchaseOrderId,
    required this.purchaseOrderName,
  });

  factory KhaltiPaymentInitiation.fromJson(Map<String, dynamic> json) {
    return KhaltiPaymentInitiation(
      paymentRecordId: json['payment_record_id'] as int,
      pidx: json['pidx'] as String,
      publicKey: json['public_key'] as String?,
      environment: json['environment'] as String,
      amount: json['amount'] as String,
      purchaseOrderId: json['purchase_order_id'] as String,
      purchaseOrderName: json['purchase_order_name'] as String,
    );
  }

  bool get isTest => environment.toLowerCase() == 'test';

  @override
  List<Object?> get props => [
    paymentRecordId,
    pidx,
    publicKey,
    environment,
    amount,
    purchaseOrderId,
    purchaseOrderName,
  ];
}
