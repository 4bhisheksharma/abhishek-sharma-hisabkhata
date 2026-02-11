import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fetch_paginated_users_usecase.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/send_bulk_connection_request_usecase.dart';
import '../../domain/usecases/send_connection_request_usecase.dart';
import '../../domain/usecases/get_sent_requests_usecase.dart';
import '../../domain/usecases/get_received_requests_usecase.dart';
import '../../domain/usecases/get_pending_received_requests_usecase.dart';
import '../../domain/usecases/get_connected_users_usecase.dart';
import '../../domain/usecases/update_request_status_usecase.dart';
import '../../domain/usecases/delete_connection_usecase.dart';
import '../../domain/usecases/cancel_connection_request_usecase.dart';
import 'connection_request_event.dart';
import 'connection_request_state.dart';

class ConnectionRequestBloc
    extends Bloc<ConnectionRequestEvent, ConnectionRequestState> {
  final SearchUsersUseCase searchUsersUseCase;
  final FetchPaginatedUsersUseCase fetchPaginatedUsersUseCase;
  final SendConnectionRequestUseCase sendConnectionRequestUseCase;
  final SendBulkConnectionRequestUseCase sendBulkConnectionRequestUseCase;
  final GetSentRequestsUseCase getSentRequestsUseCase;
  final GetReceivedRequestsUseCase getReceivedRequestsUseCase;
  final GetPendingReceivedRequestsUseCase getPendingReceivedRequestsUseCase;
  final GetConnectedUsersUseCase getConnectedUsersUseCase;
  final UpdateRequestStatusUseCase updateRequestStatusUseCase;
  final DeleteConnectionUseCase deleteConnectionUseCase;
  final CancelConnectionRequestUseCase cancelConnectionRequestUseCase;

  ConnectionRequestBloc({
    required this.searchUsersUseCase,
    required this.fetchPaginatedUsersUseCase,
    required this.sendConnectionRequestUseCase,
    required this.sendBulkConnectionRequestUseCase,
    required this.getSentRequestsUseCase,
    required this.getReceivedRequestsUseCase,
    required this.getPendingReceivedRequestsUseCase,
    required this.getConnectedUsersUseCase,
    required this.updateRequestStatusUseCase,
    required this.deleteConnectionUseCase,
    required this.cancelConnectionRequestUseCase,
  }) : super(const ConnectionRequestInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<FetchPaginatedUsersEvent>(_onFetchPaginatedUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<SendConnectionRequestEvent>(_onSendConnectionRequest);
    on<SendBulkConnectionRequestEvent>(_onSendBulkConnectionRequest);
    on<GetSentRequestsEvent>(_onGetSentRequests);
    on<GetReceivedRequestsEvent>(_onGetReceivedRequests);
    on<GetPendingReceivedRequestsEvent>(_onGetPendingReceivedRequests);
    on<GetConnectedUsersEvent>(_onGetConnectedUsers);
    on<UpdateRequestStatusEvent>(_onUpdateRequestStatus);
    on<DeleteConnectionEvent>(_onDeleteConnection);
    on<CancelConnectionRequestEvent>(_onCancelConnectionRequest);
    on<FetchAllConnectionRequestsEvent>(_onFetchAllConnectionRequests);
  }

  /// Handle search users event
  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await searchUsersUseCase(event.query);
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (users) => emit(UserSearchSuccess(users: users)),
    );
  }

  /// Handle fetch paginated users (initial load or new search)
  Future<void> _onFetchPaginatedUsers(
    FetchPaginatedUsersEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    // Show full loading only for page 1 (initial or new search)
    if (event.page == 1) {
      emit(const ConnectionRequestLoading());
    }

    final result = await fetchPaginatedUsersUseCase(
      search: event.search,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (response) => emit(
        PaginatedUsersLoaded(
          users: response.results,
          hasMore: response.hasNextPage,
          currentPage: event.page,
          totalCount: response.count,
          searchQuery: event.search,
        ),
      ),
    );
  }

  /// Handle load more users (next page)
  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PaginatedUsersLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    // Emit loading-more state (keeps existing users visible)
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await fetchPaginatedUsersUseCase(
      search: currentState.searchQuery,
      page: nextPage,
    );

    result.fold(
      (failure) {
        // On failure, revert loading-more flag
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (response) {
        // Append new users to existing list
        final allUsers = [...currentState.users, ...response.results];
        emit(
          PaginatedUsersLoaded(
            users: allUsers,
            hasMore: response.hasNextPage,
            currentPage: nextPage,
            totalCount: response.count,
            searchQuery: currentState.searchQuery,
          ),
        );
      },
    );
  }

  /// Handle send connection request event
  Future<void> _onSendConnectionRequest(
    SendConnectionRequestEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await sendConnectionRequestUseCase(
      receiverEmail: event.receiverEmail,
      receiverId: event.receiverId,
    );
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (request) => emit(ConnectionRequestSentSuccess(request: request)),
    );
  }

  /// Handle send bulk connection request event
  Future<void> _onSendBulkConnectionRequest(
    SendBulkConnectionRequestEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await sendBulkConnectionRequestUseCase(
      receiverIds: event.receiverIds,
    );
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (response) => emit(BulkConnectionRequestSuccess(response: response)),
    );
  }

  /// Handle get sent requests event
  Future<void> _onGetSentRequests(
    GetSentRequestsEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await getSentRequestsUseCase();
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (requests) => emit(SentRequestsLoaded(requests: requests)),
    );
  }

  /// Handle get received requests event
  Future<void> _onGetReceivedRequests(
    GetReceivedRequestsEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await getReceivedRequestsUseCase();
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (requests) => emit(ReceivedRequestsLoaded(requests: requests)),
    );
  }

  /// Handle get pending received requests event
  Future<void> _onGetPendingReceivedRequests(
    GetPendingReceivedRequestsEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await getPendingReceivedRequestsUseCase();
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (requests) => emit(PendingReceivedRequestsLoaded(requests: requests)),
    );
  }

  /// Handle get connected users event
  Future<void> _onGetConnectedUsers(
    GetConnectedUsersEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await getConnectedUsersUseCase();
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (connectedUsers) =>
          emit(ConnectedUsersLoaded(connectedUsers: connectedUsers)),
    );
  }

  /// Handle update request status event
  Future<void> _onUpdateRequestStatus(
    UpdateRequestStatusEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await updateRequestStatusUseCase(
      requestId: event.requestId,
      status: event.status,
    );
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (request) => emit(RequestStatusUpdated(request: request)),
    );
  }

  /// Handle delete connection event
  Future<void> _onDeleteConnection(
    DeleteConnectionEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await deleteConnectionUseCase(
      userId: event.userId,
      requestId: event.requestId,
    );
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (response) => emit(
        ConnectionDeletedSuccess(
          message: response['message'] ?? 'Connection deleted successfully',
          deletedUserInfo: response['deleted_user'] ?? {},
        ),
      ),
    );
  }

  /// Handle cancel connection request event
  Future<void> _onCancelConnectionRequest(
    CancelConnectionRequestEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());
    final result = await cancelConnectionRequestUseCase(
      requestId: event.requestId,
    );
    result.fold(
      (failure) =>
          emit(ConnectionRequestError(message: failure.failureMessage)),
      (response) {
        // After cancel, reload all requests
        add(const FetchAllConnectionRequestsEvent());
      },
    );
  }

  /// Handle fetch all (sent + received) connection requests
  Future<void> _onFetchAllConnectionRequests(
    FetchAllConnectionRequestsEvent event,
    Emitter<ConnectionRequestState> emit,
  ) async {
    emit(const ConnectionRequestLoading());

    final sentResult = await getSentRequestsUseCase();
    final receivedResult = await getReceivedRequestsUseCase();

    // If either fails, emit error
    final sentRequests = sentResult.fold(
      (failure) => null,
      (requests) => requests,
    );
    final receivedRequests = receivedResult.fold(
      (failure) => null,
      (requests) => requests,
    );

    if (sentRequests == null && receivedRequests == null) {
      emit(
        const ConnectionRequestError(
          message: 'Failed to load connection requests',
        ),
      );
      return;
    }

    emit(
      AllConnectionRequestsLoaded(
        sentRequests: sentRequests ?? [],
        receivedRequests: receivedRequests ?? [],
      ),
    );
  }
}
