import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';

import '../../domain/entities/hybrid_switch_request_entity.dart';
import '../../domain/usecases/get_hybrid_switch_status_usecase.dart';
import '../../domain/usecases/get_my_hybrid_switch_requests_usecase.dart';
import '../../domain/usecases/submit_hybrid_switch_request_usecase.dart';
import '../../domain/usecases/upload_hybrid_citizenship_usecase.dart';
import 'hybrid_switch_event.dart';
import 'hybrid_switch_state.dart';

class HybridSwitchBloc extends Bloc<HybridSwitchEvent, HybridSwitchState> {
  final GetHybridSwitchStatusUseCase getHybridSwitchStatusUseCase;
  final GetMyHybridSwitchRequestsUseCase getMyHybridSwitchRequestsUseCase;
  final UploadHybridCitizenshipUseCase uploadHybridCitizenshipUseCase;
  final SubmitHybridSwitchRequestUseCase submitHybridSwitchRequestUseCase;

  HybridSwitchBloc({
    required this.getHybridSwitchStatusUseCase,
    required this.getMyHybridSwitchRequestsUseCase,
    required this.uploadHybridCitizenshipUseCase,
    required this.submitHybridSwitchRequestUseCase,
  }) : super(const HybridSwitchInitial()) {
    on<HybridSwitchLoadRequested>(_onLoadRequested);
    on<HybridSwitchRefreshRequested>(_onRefreshRequested);
    on<HybridSwitchCitizenshipUploadRequested>(_onUploadRequested);
    on<HybridSwitchSubmitRequested>(_onSubmitRequested);
    on<HybridSwitchClearMessageRequested>(_onClearMessageRequested);
  }

  Future<void> _onLoadRequested(
    HybridSwitchLoadRequested event,
    Emitter<HybridSwitchState> emit,
  ) async {
    emit(const HybridSwitchLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    HybridSwitchRefreshRequested event,
    Emitter<HybridSwitchState> emit,
  ) async {
    if (state is! HybridSwitchLoaded) {
      emit(const HybridSwitchLoading());
    }
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HybridSwitchState> emit) async {
    final statusResult = await getHybridSwitchStatusUseCase(NoParams());
    final requestsResult = await getMyHybridSwitchRequestsUseCase(NoParams());

    statusResult.fold(
      (failure) => emit(HybridSwitchError(failure.failureMessage)),
      (status) {
        requestsResult.fold(
          (failure) => emit(HybridSwitchError(failure.failureMessage)),
          (requests) =>
              emit(HybridSwitchLoaded(status: status, requests: requests)),
        );
      },
    );
  }

  Future<void> _onUploadRequested(
    HybridSwitchCitizenshipUploadRequested event,
    Emitter<HybridSwitchState> emit,
  ) async {
    final current = state;
    if (current is! HybridSwitchLoaded) return;

    emit(current.copyWith(isUploading: true, clearMessage: true));

    final result = await uploadHybridCitizenshipUseCase(
      UploadHybridCitizenshipParams(citizenshipFile: event.citizenshipFile),
    );

    result.fold((failure) => emit(HybridSwitchError(failure.failureMessage)), (
      uploaded,
    ) {
      final updatedRequests = _mergeLatestRequest(current.requests, uploaded);
      emit(
        current.copyWith(
          requests: updatedRequests,
          isUploading: false,
          message: 'Citizenship uploaded successfully.',
        ),
      );
    });
  }

  Future<void> _onSubmitRequested(
    HybridSwitchSubmitRequested event,
    Emitter<HybridSwitchState> emit,
  ) async {
    final current = state;
    if (current is! HybridSwitchLoaded) return;

    emit(current.copyWith(isSubmitting: true, clearMessage: true));

    final result = await submitHybridSwitchRequestUseCase(
      SubmitHybridSwitchRequestParams(hybridRequestId: event.hybridRequestId),
    );

    result.fold((failure) => emit(HybridSwitchError(failure.failureMessage)), (
      submitted,
    ) {
      final updatedRequests = _mergeLatestRequest(current.requests, submitted);
      emit(
        current.copyWith(
          requests: updatedRequests,
          isSubmitting: false,
          message: 'Hybrid switch request submitted successfully.',
        ),
      );
    });
  }

  void _onClearMessageRequested(
    HybridSwitchClearMessageRequested event,
    Emitter<HybridSwitchState> emit,
  ) {
    final current = state;
    if (current is HybridSwitchLoaded) {
      emit(current.copyWith(clearMessage: true));
    }
  }

  List<HybridSwitchRequestEntity> _mergeLatestRequest(
    List<HybridSwitchRequestEntity> current,
    HybridSwitchRequestEntity incoming,
  ) {
    final remaining = current.where((item) => item.id != incoming.id).toList();
    return [incoming, ...remaining];
  }
}
