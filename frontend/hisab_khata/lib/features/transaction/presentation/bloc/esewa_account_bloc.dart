import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/esewa_repository.dart';
import 'esewa_account_event.dart';
import 'esewa_account_state.dart';

/// BLoC for managing business eSewa account linking/unlinking
class EsewaAccountBloc extends Bloc<EsewaAccountEvent, EsewaAccountState> {
  final EsewaRepository _repository;

  EsewaAccountBloc({required EsewaRepository repository})
    : _repository = repository,
      super(const EsewaAccountInitial()) {
    on<LoadEsewaAccount>(_onLoad);
    on<LinkEsewaAccount>(_onLink);
    on<UpdateEsewaAccount>(_onUpdate);
    on<UnlinkEsewaAccount>(_onUnlink);
  }

  Future<void> _onLoad(
    LoadEsewaAccount event,
    Emitter<EsewaAccountState> emit,
  ) async {
    emit(const EsewaAccountLoading());
    try {
      final account = await _repository.getBusinessEsewaAccount();
      emit(EsewaAccountLoaded(account));
    } catch (e) {
      emit(EsewaAccountError(e.toString()));
    }
  }

  Future<void> _onLink(
    LinkEsewaAccount event,
    Emitter<EsewaAccountState> emit,
  ) async {
    emit(const EsewaAccountActionLoading(null));
    try {
      final account = await _repository.linkEsewaAccount(
        esewaId: event.esewaId,
        accountName: event.accountName,
      );
      emit(
        EsewaAccountActionSuccess(
          'eSewa account linked successfully',
          account: account,
        ),
      );
      emit(EsewaAccountLoaded(account));
    } catch (e) {
      emit(EsewaAccountError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateEsewaAccount event,
    Emitter<EsewaAccountState> emit,
  ) async {
    final currentAccount = state is EsewaAccountLoaded
        ? (state as EsewaAccountLoaded).account
        : null;
    emit(EsewaAccountActionLoading(currentAccount));
    try {
      final account = await _repository.updateEsewaAccount(
        esewaId: event.esewaId,
        accountName: event.accountName,
      );
      emit(
        EsewaAccountActionSuccess(
          'eSewa account updated successfully',
          account: account,
        ),
      );
      emit(EsewaAccountLoaded(account));
    } catch (e) {
      emit(EsewaAccountError(e.toString(), currentAccount: currentAccount));
    }
  }

  Future<void> _onUnlink(
    UnlinkEsewaAccount event,
    Emitter<EsewaAccountState> emit,
  ) async {
    final currentAccount = state is EsewaAccountLoaded
        ? (state as EsewaAccountLoaded).account
        : null;
    emit(EsewaAccountActionLoading(currentAccount));
    try {
      await _repository.unlinkEsewaAccount();
      emit(
        const EsewaAccountActionSuccess('eSewa account unlinked successfully'),
      );
      emit(const EsewaAccountLoaded(null));
    } catch (e) {
      emit(EsewaAccountError(e.toString(), currentAccount: currentAccount));
    }
  }
}
