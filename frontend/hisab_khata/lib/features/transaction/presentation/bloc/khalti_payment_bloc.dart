import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/khalti_repository.dart';
import 'khalti_payment_event.dart';
import 'khalti_payment_state.dart';

class KhaltiPaymentBloc extends Bloc<KhaltiPaymentEvent, KhaltiPaymentState> {
  final KhaltiRepository _repository;

  KhaltiPaymentBloc({required KhaltiRepository repository})
    : _repository = repository,
      super(const KhaltiPaymentInitial()) {
    on<CheckKhaltiStatus>(_onCheckStatus);
    on<InitiateKhaltiPayment>(_onInitiate);
    on<VerifyKhaltiPayment>(_onVerify);
    on<ResetKhaltiPayment>(_onReset);
  }

  Future<void> _onCheckStatus(
    CheckKhaltiStatus event,
    Emitter<KhaltiPaymentState> emit,
  ) async {
    emit(const KhaltiStatusChecking());
    try {
      final status = await _repository.checkBusinessKhaltiStatus(
        event.relationshipId,
      );
      emit(KhaltiStatusLoaded(status));
    } catch (e) {
      emit(KhaltiPaymentFailed(e.toString()));
    }
  }

  Future<void> _onInitiate(
    InitiateKhaltiPayment event,
    Emitter<KhaltiPaymentState> emit,
  ) async {
    emit(const KhaltiPaymentInitiating());
    try {
      final paymentData = await _repository.initiateKhaltiPayment(
        relationshipId: event.relationshipId,
        amount: event.amount,
        description: event.description,
      );
      emit(KhaltiPaymentInitiated(paymentData));
    } catch (e) {
      emit(KhaltiPaymentFailed(e.toString()));
    }
  }

  Future<void> _onVerify(
    VerifyKhaltiPayment event,
    Emitter<KhaltiPaymentState> emit,
  ) async {
    emit(const KhaltiPaymentVerifying());
    try {
      final success = await _repository.verifyKhaltiPayment(
        paymentRecordId: event.paymentRecordId,
        pidx: event.pidx,
        transactionId: event.transactionId,
        totalAmount: event.totalAmount,
        status: event.status,
        khaltiResponse: event.khaltiResponse,
      );
      if (success) {
        emit(
          const KhaltiPaymentVerified(
            'Payment verified and recorded successfully!',
          ),
        );
      } else {
        emit(const KhaltiPaymentFailed('Payment verification failed'));
      }
    } catch (e) {
      emit(KhaltiPaymentFailed(e.toString()));
    }
  }

  void _onReset(ResetKhaltiPayment event, Emitter<KhaltiPaymentState> emit) {
    emit(const KhaltiPaymentInitial());
  }
}
