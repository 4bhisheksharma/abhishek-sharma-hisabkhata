import 'package:equatable/equatable.dart';

/// Events for eSewa Payment BLoC (Customer side)
abstract class EsewaPaymentEvent extends Equatable {
  const EsewaPaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Check if business has eSewa linked
class CheckEsewaStatus extends EsewaPaymentEvent {
  final int relationshipId;

  const CheckEsewaStatus(this.relationshipId);

  @override
  List<Object?> get props => [relationshipId];
}

/// Initiate eSewa payment (step 1: create backend record)
class InitiateEsewaPayment extends EsewaPaymentEvent {
  final int relationshipId;
  final double amount;
  final String? description;

  const InitiateEsewaPayment({
    required this.relationshipId,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [relationshipId, amount, description];
}

/// Verify eSewa payment after SDK success (step 2: verify with backend)
class VerifyEsewaPayment extends EsewaPaymentEvent {
  final int paymentRecordId;
  final String esewaRefId;
  final String esewaProductId;
  final String totalAmount;
  final String status;
  final Map<String, dynamic>? esewaResponse;

  const VerifyEsewaPayment({
    required this.paymentRecordId,
    required this.esewaRefId,
    required this.esewaProductId,
    required this.totalAmount,
    required this.status,
    this.esewaResponse,
  });

  @override
  List<Object?> get props => [
    paymentRecordId,
    esewaRefId,
    esewaProductId,
    totalAmount,
    status,
    esewaResponse,
  ];
}

/// Reset payment state
class ResetEsewaPayment extends EsewaPaymentEvent {
  const ResetEsewaPayment();
}
