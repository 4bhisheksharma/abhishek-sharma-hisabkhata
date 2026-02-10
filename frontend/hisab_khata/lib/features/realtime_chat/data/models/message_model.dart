import '../../domain/entities/message_entity.dart';
import 'chat_user_model.dart';

/// Model for message data from API/WebSocket.
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.chatRoomId,
    required super.sender,
    required super.content,
    required super.messageType,
    required super.isRead,
    super.readAt,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] as int,
      chatRoomId: json['chat_room'] is int
          ? json['chat_room'] as int
          : (json['chat_room'] as Map<String, dynamic>)['chat_room_id'] as int,
      sender: ChatUserModel.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Create from WebSocket message format.
  factory MessageModel.fromWebSocketJson(
    Map<String, dynamic> json, {
    required int chatRoomId,
  }) {
    return MessageModel(
      messageId: json['message_id'] as int,
      chatRoomId: chatRoomId,
      sender: ChatUserModel(
        userId: json['sender_id'] as int,
        fullName: json['sender_name'] as String,
        email: '', // Not provided in WebSocket messages
      ),
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'chat_room': chatRoomId,
      'content': content,
      'message_type': messageType,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
