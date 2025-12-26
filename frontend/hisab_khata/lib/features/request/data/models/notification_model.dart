import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.notificationId,
    required super.sender,
    required super.senderEmail,
    required super.senderName,
    required super.receiver,
    required super.receiverEmail,
    required super.receiverName,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      sender: json['sender'],
      senderEmail: json['sender_email'],
      senderName: json['sender_name'],
      receiver: json['receiver'],
      receiverEmail: json['receiver_email'],
      receiverName: json['receiver_name'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'sender': sender,
      'sender_email': senderEmail,
      'sender_name': senderName,
      'receiver': receiver,
      'receiver_email': receiverEmail,
      'receiver_name': receiverName,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
