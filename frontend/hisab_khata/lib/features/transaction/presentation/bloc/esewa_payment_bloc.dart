import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/esewa_repository.dart';
import 'esewa_payment_event.dart';
import 'esewa_payment_state.dart';

/// BLoC for managing eSewa payments from customer side
class EsewaPaymentBloc extends Bloc<EsewaPaymentEvent, EsewaPaymentState> {
  final EsewaRepository _repository;

  EsewaPaymentBloc({required EsewaRepository repository})
    : _repository = repository,
      super(const EsewaPaymentInitial()) {
    on<CheckEsewaStatus>(_onCheckStatus);
    on<InitiateEsewaPayment>(_onInitiate);
    on<VerifyEsewaPayment>(_onVerify);
    on<ResetEsewaPayment>(_onReset);
  }

  Future<void> _onCheckStatus(
    CheckEsewaStatus event,
    Emitter<EsewaPaymentState> emit,
  ) async {
    emit(const EsewaStatusChecking());
    try {
      final status = await _repository.checkBusinessEsewaStatus(
        event.relationshipId,
      );
      emit(EsewaStatusLoaded(status));
    } catch (e) {
      emit(EsewaPaymentFailed(e.toString()));
    }
  }

  Future<void> _onInitiate(
    InitiateEsewaPayment event,
    Emitter<EsewaPaymentState> emit,
  ) async {
    emit(const EsewaPaymentInitiating());
    try {
      final paymentData = await _repository.initiateEsewaPayment(
        relationshipId: event.relationshipId,
        amount: event.amount,
        description: event.description,
      );
      emit(EsewaPaymentInitiated(paymentData));
    } catch (e) {
      emit(EsewaPaymentFailed(e.toString()));
    }
  }

  Future<void> _onVerify(
    VerifyEsewaPayment event,
    Emitter<EsewaPaymentState> emit,
  ) async {
    emit(const EsewaPaymentVerifying());
    try {
      final success = await _repository.verifyEsewaPayment(
        paymentRecordId: event.paymentRecordId,
        esewaRefId: event.esewaRefId,
        esewaProductId: event.esewaProductId,
        totalAmount: event.totalAmount,
        status: event.status,
        esewaResponse: event.esewaResponse,
      );

      if (success) {
        emit(
          const EsewaPaymentVerified(
            'Payment verified and recorded successfully!',
          ),
        );
      } else {
        emit(const EsewaPaymentFailed('Payment verification failed'));
      }
    } catch (e) {
      emit(EsewaPaymentFailed(e.toString()));
    }
  }

  void _onReset(ResetEsewaPayment event, Emitter<EsewaPaymentState> emit) {
    emit(const EsewaPaymentInitial());
  }
}
