import 'package:equatable/equatable.dart';
import '../../domain/entities/esewa_entities.dart';

/// States for eSewa Payment BLoC (Customer side)
abstract class EsewaPaymentState extends Equatable {
  const EsewaPaymentState();

  @override
  List<Object?> get props => [];
}

class EsewaPaymentInitial extends EsewaPaymentState {
  const EsewaPaymentInitial();
}

/// Checking if business has eSewa
class EsewaStatusChecking extends EsewaPaymentState {
  const EsewaStatusChecking();
}

/// Business eSewa status loaded
class EsewaStatusLoaded extends EsewaPaymentState {
  final BusinessEsewaStatus esewaStatus;

  const EsewaStatusLoaded(this.esewaStatus);

  @override
  List<Object?> get props => [esewaStatus];
}

/// Payment is being initiated with backend
class EsewaPaymentInitiating extends EsewaPaymentState {
  const EsewaPaymentInitiating();
}

/// Backend returned payment params, ready for SDK call
class EsewaPaymentInitiated extends EsewaPaymentState {
  final EsewaPaymentInitiation paymentData;

  const EsewaPaymentInitiated(this.paymentData);

  @override
  List<Object?> get props => [paymentData];
}

/// Payment is being verified with backend
class EsewaPaymentVerifying extends EsewaPaymentState {
  const EsewaPaymentVerifying();
}

/// Payment verified successfully
class EsewaPaymentVerified extends EsewaPaymentState {
  final String message;

  const EsewaPaymentVerified(this.message);

  @override
  List<Object?> get props => [message];
}

/// Payment failed at any stage
class EsewaPaymentFailed extends EsewaPaymentState {
  final String message;

  const EsewaPaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}
