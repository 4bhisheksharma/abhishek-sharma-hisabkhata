import 'package:equatable/equatable.dart';

/// Base connection request event
abstract class ConnectionRequestEvent extends Equatable {
  const ConnectionRequestEvent();

  @override
  List<Object?> get props => [];
}

/// Search users event
class SearchUsersEvent extends ConnectionRequestEvent {
  final String query;

  const SearchUsersEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Send connection request event
class SendConnectionRequestEvent extends ConnectionRequestEvent {
  final String? receiverEmail;
  final int? receiverId;

  const SendConnectionRequestEvent({this.receiverEmail, this.receiverId});

  @override
  List<Object?> get props => [receiverEmail, receiverId];
}

/// Send bulk connection request event
class SendBulkConnectionRequestEvent extends ConnectionRequestEvent {
  final List<int> receiverIds;

  const SendBulkConnectionRequestEvent({required this.receiverIds});

  @override
  List<Object?> get props => [receiverIds];
}

/// Get sent requests event
class GetSentRequestsEvent extends ConnectionRequestEvent {
  const GetSentRequestsEvent();
}

/// Get received requests event
class GetReceivedRequestsEvent extends ConnectionRequestEvent {
  const GetReceivedRequestsEvent();
}

/// Get pending received requests event
class GetPendingReceivedRequestsEvent extends ConnectionRequestEvent {
  const GetPendingReceivedRequestsEvent();
}

/// Get connected users event
class GetConnectedUsersEvent extends ConnectionRequestEvent {
  const GetConnectedUsersEvent();
}

/// Fetch paginated users (initial load or search)
class FetchPaginatedUsersEvent extends ConnectionRequestEvent {
  final String? search;
  final int page;
  final int pageSize;

  const FetchPaginatedUsersEvent({
    this.search,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [search, page, pageSize];
}

/// Load next page of paginated users
class LoadMoreUsersEvent extends ConnectionRequestEvent {
  const LoadMoreUsersEvent();
}

/// Update request status event
class UpdateRequestStatusEvent extends ConnectionRequestEvent {
  final int requestId;
  final String status;

  const UpdateRequestStatusEvent({
    required this.requestId,
    required this.status,
  });

  @override
  List<Object?> get props => [requestId, status];
}

/// Delete connection event
class DeleteConnectionEvent extends ConnectionRequestEvent {
  final int? userId;
  final int? requestId;

  const DeleteConnectionEvent({this.userId, this.requestId});

  @override
  List<Object?> get props => [userId, requestId];
}

/// Cancel a sent connection request event
class CancelConnectionRequestEvent extends ConnectionRequestEvent {
  final int requestId;

  const CancelConnectionRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Fetch both sent and received requests for the connection requests screen
class FetchAllConnectionRequestsEvent extends ConnectionRequestEvent {
  const FetchAllConnectionRequestsEvent();
}
