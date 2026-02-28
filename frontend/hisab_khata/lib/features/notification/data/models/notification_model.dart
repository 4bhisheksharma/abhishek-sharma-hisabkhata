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
    required super.data,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] as int? ?? 0,
      sender: json['sender'] as int? ?? 0,
      senderEmail: json['sender_email'] as String? ?? 'system',
      senderName: json['sender_name'] as String? ?? 'Hisab Khata',
      receiver: json['receiver'] as int? ?? 0,
      receiverEmail: json['receiver_email'] as String? ?? '',
      receiverName: json['receiver_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
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
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
