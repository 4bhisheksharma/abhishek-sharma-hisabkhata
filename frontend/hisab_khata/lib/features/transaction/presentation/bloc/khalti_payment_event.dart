import 'package:equatable/equatable.dart';

abstract class KhaltiPaymentEvent extends Equatable {
  const KhaltiPaymentEvent();

  @override
  List<Object?> get props => [];
}

class CheckKhaltiStatus extends KhaltiPaymentEvent {
  final int relationshipId;

  const CheckKhaltiStatus(this.relationshipId);

  @override
  List<Object?> get props => [relationshipId];
}

class InitiateKhaltiPayment extends KhaltiPaymentEvent {
  final int relationshipId;
  final double amount;
  final String? description;

  const InitiateKhaltiPayment({
    required this.relationshipId,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [relationshipId, amount, description];
}

class VerifyKhaltiPayment extends KhaltiPaymentEvent {
  final int paymentRecordId;
  final String pidx;
  final String? transactionId;
  final String? totalAmount;
  final String? status;
  final Map<String, dynamic>? khaltiResponse;

  const VerifyKhaltiPayment({
    required this.paymentRecordId,
    required this.pidx,
    this.transactionId,
    this.totalAmount,
    this.status,
    this.khaltiResponse,
  });

  @override
  List<Object?> get props => [
    paymentRecordId,
    pidx,
    transactionId,
    totalAmount,
    status,
    khaltiResponse,
  ];
}

class ResetKhaltiPayment extends KhaltiPaymentEvent {
  const ResetKhaltiPayment();
}
