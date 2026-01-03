import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'connected_user_details_event.dart';
import 'connected_user_details_state.dart';

class ConnectedUserDetailsBloc
    extends Bloc<ConnectedUserDetailsEvent, ConnectedUserDetailsState> {
  final TransactionRepository _repository;

  ConnectedUserDetailsBloc({required TransactionRepository repository})
    : _repository = repository,
      super(const ConnectedUserDetailsInitial()) {
    on<LoadConnectedUserDetails>(_onLoadConnectedUserDetails);
    on<RefreshConnectedUserDetails>(_onRefreshConnectedUserDetails);
    on<ToggleFavorite>(_onToggleFavorite);
    on<CreateTransaction>(_onCreateTransaction);
  }

  Future<void> _onLoadConnectedUserDetails(
    LoadConnectedUserDetails event,
    Emitter<ConnectedUserDetailsState> emit,
  ) async {
    emit(const ConnectedUserDetailsLoading());
    try {
      final userDetails = await _repository.getConnectedUserDetails(
        event.relationshipId,
      );
      emit(ConnectedUserDetailsLoaded(userDetails));
    } catch (e) {
      emit(ConnectedUserDetailsError(e.toString()));
    }
  }

  Future<void> _onRefreshConnectedUserDetails(
    RefreshConnectedUserDetails event,
    Emitter<ConnectedUserDetailsState> emit,
  ) async {
    try {
      final userDetails = await _repository.getConnectedUserDetails(
        event.relationshipId,
      );
      emit(ConnectedUserDetailsLoaded(userDetails));
    } catch (e) {
      emit(ConnectedUserDetailsError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<ConnectedUserDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConnectedUserDetailsLoaded) return;

    emit(ConnectedUserDetailsFavoriteToggling(currentState.userDetails));

    try {
      if (event.currentStatus) {
        await _repository.removeFromFavorites(event.businessId);
      } else {
        await _repository.addToFavorites(event.businessId);
      }

      // Update the user details with new favorite status
      final updatedDetails = currentState.userDetails.copyWith(
        isFavorite: !event.currentStatus,
      );
      emit(ConnectedUserDetailsLoaded(updatedDetails));
    } catch (e) {
      // Revert to previous state on error
      emit(ConnectedUserDetailsLoaded(currentState.userDetails));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<ConnectedUserDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConnectedUserDetailsLoaded) return;

    emit(ConnectedUserDetailsTransactionCreating(currentState.userDetails));

    try {
      await _repository.createTransaction(
        relationshipId: event.relationshipId,
        amount: event.amount,
        type: event.type,
        description: event.description,
      );

      // Refresh the user details to get updated transactions and totals
      final updatedDetails = await _repository.getConnectedUserDetails(
        event.relationshipId,
      );
      emit(ConnectedUserDetailsLoaded(updatedDetails));
    } catch (e) {
      emit(ConnectedUserDetailsError(e.toString()));
    }
  }
}
