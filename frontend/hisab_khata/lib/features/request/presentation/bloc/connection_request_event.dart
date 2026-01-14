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
