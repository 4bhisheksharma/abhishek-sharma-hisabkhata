import 'package:equatable/equatable.dart';

class UserSearchResult extends Equatable {
  final int userId;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePicture;
  final String? connectionStatus; // null, 'pending', 'accepted', 'rejected'
  final int? requestId;
  final bool? isSender;

  const UserSearchResult({
    required this.userId,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePicture,
    this.connectionStatus,
    this.requestId,
    this.isSender,
  });

  bool get hasConnection => connectionStatus != null;
  bool get isPending => connectionStatus == 'pending';
  bool get isAccepted => connectionStatus == 'accepted';
  bool get isRejected => connectionStatus == 'rejected';
  bool get canSendRequest => connectionStatus == null;

  @override
  List<Object?> get props => [
    userId,
    email,
    phoneNumber,
    fullName,
    profilePicture,
    connectionStatus,
    requestId,
    isSender,
  ];
}
