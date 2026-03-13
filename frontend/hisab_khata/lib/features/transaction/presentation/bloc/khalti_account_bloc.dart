import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/khalti_repository.dart';
import 'khalti_account_event.dart';
import 'khalti_account_state.dart';

class KhaltiAccountBloc extends Bloc<KhaltiAccountEvent, KhaltiAccountState> {
  final KhaltiRepository _repository;

  KhaltiAccountBloc({required KhaltiRepository repository})
    : _repository = repository,
      super(const KhaltiAccountInitial()) {
    on<LoadKhaltiAccount>(_onLoad);
    on<LinkKhaltiAccount>(_onLink);
    on<UpdateKhaltiAccount>(_onUpdate);
    on<UnlinkKhaltiAccount>(_onUnlink);
  }

  Future<void> _onLoad(
    LoadKhaltiAccount event,
    Emitter<KhaltiAccountState> emit,
  ) async {
    emit(const KhaltiAccountLoading());
    try {
      final account = await _repository.getBusinessKhaltiAccount();
      emit(KhaltiAccountLoaded(account));
    } catch (e) {
      emit(KhaltiAccountError(e.toString()));
    }
  }

  Future<void> _onLink(
    LinkKhaltiAccount event,
    Emitter<KhaltiAccountState> emit,
  ) async {
    emit(const KhaltiAccountActionLoading(null));
    try {
      final account = await _repository.linkKhaltiAccount(
        khaltiId: event.khaltiId,
        accountName: event.accountName,
      );
      emit(
        KhaltiAccountActionSuccess(
          'Khalti account linked successfully',
          account: account,
        ),
      );
      emit(KhaltiAccountLoaded(account));
    } catch (e) {
      emit(KhaltiAccountError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateKhaltiAccount event,
    Emitter<KhaltiAccountState> emit,
  ) async {
    final currentAccount = state is KhaltiAccountLoaded
        ? (state as KhaltiAccountLoaded).account
        : null;
    emit(KhaltiAccountActionLoading(currentAccount));
    try {
      final account = await _repository.updateKhaltiAccount(
        khaltiId: event.khaltiId,
        accountName: event.accountName,
      );
      emit(
        KhaltiAccountActionSuccess(
          'Khalti account updated successfully',
          account: account,
        ),
      );
      emit(KhaltiAccountLoaded(account));
    } catch (e) {
      emit(KhaltiAccountError(e.toString(), currentAccount: currentAccount));
    }
  }

  Future<void> _onUnlink(
    UnlinkKhaltiAccount event,
    Emitter<KhaltiAccountState> emit,
  ) async {
    final currentAccount = state is KhaltiAccountLoaded
        ? (state as KhaltiAccountLoaded).account
        : null;
    emit(KhaltiAccountActionLoading(currentAccount));
    try {
      await _repository.unlinkKhaltiAccount();
      emit(
        const KhaltiAccountActionSuccess(
          'Khalti account unlinked successfully',
        ),
      );
      emit(const KhaltiAccountLoaded(null));
    } catch (e) {
      emit(KhaltiAccountError(e.toString(), currentAccount: currentAccount));
    }
  }
}
