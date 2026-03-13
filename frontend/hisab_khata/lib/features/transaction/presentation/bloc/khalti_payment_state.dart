import 'package:equatable/equatable.dart';
import '../../domain/entities/khalti_entities.dart';

abstract class KhaltiPaymentState extends Equatable {
  const KhaltiPaymentState();

  @override
  List<Object?> get props => [];
}

class KhaltiPaymentInitial extends KhaltiPaymentState {
  const KhaltiPaymentInitial();
}

class KhaltiStatusChecking extends KhaltiPaymentState {
  const KhaltiStatusChecking();
}

class KhaltiStatusLoaded extends KhaltiPaymentState {
  final BusinessKhaltiStatus khaltiStatus;

  const KhaltiStatusLoaded(this.khaltiStatus);

  @override
  List<Object?> get props => [khaltiStatus];
}

class KhaltiPaymentInitiating extends KhaltiPaymentState {
  const KhaltiPaymentInitiating();
}

class KhaltiPaymentInitiated extends KhaltiPaymentState {
  final KhaltiPaymentInitiation paymentData;

  const KhaltiPaymentInitiated(this.paymentData);

  @override
  List<Object?> get props => [paymentData];
}

class KhaltiPaymentVerifying extends KhaltiPaymentState {
  const KhaltiPaymentVerifying();
}

class KhaltiPaymentVerified extends KhaltiPaymentState {
  final String message;

  const KhaltiPaymentVerified(this.message);

  @override
  List<Object?> get props => [message];
}

class KhaltiPaymentFailed extends KhaltiPaymentState {
  final String message;

  const KhaltiPaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}
