import 'package:equatable/equatable.dart';
import '../../domain/entities/connection_request.dart';
import '../../domain/entities/user_search_result.dart';

/// Base connection request state
abstract class ConnectionRequestState extends Equatable {
  const ConnectionRequestState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConnectionRequestInitial extends ConnectionRequestState {
  const ConnectionRequestInitial();
}

/// Loading state
class ConnectionRequestLoading extends ConnectionRequestState {
  const ConnectionRequestLoading();
}

/// User search success state
class UserSearchSuccess extends ConnectionRequestState {
  final List<UserSearchResult> users;

  const UserSearchSuccess({required this.users});

  @override
  List<Object?> get props => [users];
}

/// Connection request sent success state
class ConnectionRequestSentSuccess extends ConnectionRequestState {
  final ConnectionRequest request;
  final String message;

  const ConnectionRequestSentSuccess({
    required this.request,
    this.message = 'Connection request sent successfully',
  });

  @override
  List<Object?> get props => [request, message];
}

/// Sent requests loaded state
class SentRequestsLoaded extends ConnectionRequestState {
  final List<ConnectionRequest> requests;

  const SentRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

/// Received requests loaded state
class ReceivedRequestsLoaded extends ConnectionRequestState {
  final List<ConnectionRequest> requests;

  const ReceivedRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

/// Pending received requests loaded state
class PendingReceivedRequestsLoaded extends ConnectionRequestState {
  final List<ConnectionRequest> requests;

  const PendingReceivedRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

/// Connected users loaded state
class ConnectedUsersLoaded extends ConnectionRequestState {
  final List<ConnectionRequest> connections;

  const ConnectedUsersLoaded({required this.connections});

  @override
  List<Object?> get props => [connections];
}

/// Request status updated state
class RequestStatusUpdated extends ConnectionRequestState {
  final ConnectionRequest request;
  final String message;

  const RequestStatusUpdated({
    required this.request,
    this.message = 'Request status updated successfully',
  });

  @override
  List<Object?> get props => [request, message];
}

/// Error state
class ConnectionRequestError extends ConnectionRequestState {
  final String message;

  const ConnectionRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
