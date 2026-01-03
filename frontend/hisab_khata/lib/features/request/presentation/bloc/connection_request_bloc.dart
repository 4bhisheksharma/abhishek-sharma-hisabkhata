import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/send_connection_request_usecase.dart';
import '../../domain/usecases/get_sent_requests_usecase.dart';
import '../../domain/usecases/get_received_requests_usecase.dart';
import '../../domain/usecases/get_pending_received_requests_usecase.dart';
import '../../domain/usecases/get_connected_users_usecase.dart';
import '../../domain/usecases/update_request_status_usecase.dart';
import 'connection_request_event.dart';
import 'connection_request_state.dart';

class ConnectionRequestBloc
    extends Bloc<ConnectionRequestEvent, ConnectionRequestState> {
  final SearchUsersUseCase searchUsersUseCase;
  final SendConnectionRequestUseCase sendConnectionRequestUseCase;
  final GetSentRequestsUseCase getSentRequestsUseCase;
  final GetReceivedRequestsUseCase getReceivedRequestsUseCase;
  final GetPendingReceivedRequestsUseCase getPendingReceivedRequestsUseCase;
  final GetConnectedUsersUseCase getConnectedUsersUseCase;
  final UpdateRequestStatusUseCase updateRequestStatusUseCase;

  ConnectionRequestBloc({
    required this.searchUsersUseCase,
    required this.sendConnectionRequestUseCase,
    required this.getSentRequestsUseCase,
    required this.getReceivedRequestsUseCase,
    required this.getPendingReceivedRequestsUseCase,
    required this.getConnectedUsersUseCase,
    required this.updateRequestStatusUseCase,
  }) : super(const ConnectionRequestInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<SendConnectionRequestEvent>(_onSendConnectionRequest);
    on<GetSentRequestsEvent>(_onGetSentRequests);
    on<GetReceivedRequestsEvent>(_onGetReceivedRequests);
    on<GetPendingReceivedRequestsEvent>(_onGetPendingReceivedRequests);
    on<GetConnectedUsersEvent>(_onGetConnectedUsers);
    on<UpdateRequestStatusEvent>(_onUpdateRequestStatus);
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
}
