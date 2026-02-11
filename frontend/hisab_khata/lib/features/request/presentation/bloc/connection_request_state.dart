import 'package:equatable/equatable.dart';
import '../../domain/entities/bulk_send_request_response.dart';
import '../../domain/entities/connection_request.dart';
import '../../domain/entities/connected_user.dart';
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

/// Bulk connection request sent success state
class BulkConnectionRequestSuccess extends ConnectionRequestState {
  final BulkSendRequestResponse response;

  const BulkConnectionRequestSuccess({required this.response});

  @override
  List<Object?> get props => [response];
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
  final List<ConnectedUser> connectedUsers;

  const ConnectedUsersLoaded({required this.connectedUsers});

  @override
  List<Object?> get props => [connectedUsers];
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

/// Connection deleted success state
class ConnectionDeletedSuccess extends ConnectionRequestState {
  final String message;
  final Map<String, dynamic> deletedUserInfo;

  const ConnectionDeletedSuccess({
    required this.message,
    required this.deletedUserInfo,
  });

  @override
  List<Object?> get props => [message, deletedUserInfo];
}

/// Error state
class ConnectionRequestError extends ConnectionRequestState {
  final String message;

  const ConnectionRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Combined sent + received requests loaded state
class AllConnectionRequestsLoaded extends ConnectionRequestState {
  final List<ConnectionRequest> sentRequests;
  final List<ConnectionRequest> receivedRequests;

  const AllConnectionRequestsLoaded({
    required this.sentRequests,
    required this.receivedRequests,
  });

  @override
  List<Object?> get props => [sentRequests, receivedRequests];
}

/// Paginated users loaded state — used by the bulk add screen
class PaginatedUsersLoaded extends ConnectionRequestState {
  final List<UserSearchResult> users;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final bool isLoadingMore;
  final String? searchQuery;

  const PaginatedUsersLoaded({
    required this.users,
    required this.hasMore,
    required this.currentPage,
    required this.totalCount,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  PaginatedUsersLoaded copyWith({
    List<UserSearchResult>? users,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return PaginatedUsersLoaded(
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    users,
    hasMore,
    currentPage,
    totalCount,
    isLoadingMore,
    searchQuery,
  ];
}
