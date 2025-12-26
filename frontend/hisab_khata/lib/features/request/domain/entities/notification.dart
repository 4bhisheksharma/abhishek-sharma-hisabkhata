import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int notificationId;
  final int sender;
  final String senderEmail;
  final String senderName;
  final int receiver;
  final String receiverEmail;
  final String receiverName;
  final String title;
  final String message;
  final String
  type; // 'connection_request', 'connection_request_accepted', 'connection_request_rejected'
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.notificationId,
    required this.sender,
    required this.senderEmail,
    required this.senderName,
    required this.receiver,
    required this.receiverEmail,
    required this.receiverName,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isConnectionRequest => type == 'connection_request';
  bool get isConnectionAccepted => type == 'connection_request_accepted';
  bool get isConnectionRejected => type == 'connection_request_rejected';

  Notification copyWith({
    int? notificationId,
    int? sender,
    String? senderEmail,
    String? senderName,
    int? receiver,
    String? receiverEmail,
    String? receiverName,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      sender: sender ?? this.sender,
      senderEmail: senderEmail ?? this.senderEmail,
      senderName: senderName ?? this.senderName,
      receiver: receiver ?? this.receiver,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverName: receiverName ?? this.receiverName,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    sender,
    senderEmail,
    senderName,
    receiver,
    receiverEmail,
    receiverName,
    title,
    message,
    type,
    isRead,
    createdAt,
    updatedAt,
  ];
}
