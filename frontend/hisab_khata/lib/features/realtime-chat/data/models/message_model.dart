enum MessageTypeModel { text, image, file, transactionUpdate, system }

class MessageModel {
  final int messageId;
  final int chatRoomId;
  final int senderId;
  final MessageTypeModel messageType;
  final String content;
  final String? fileUrl;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.messageId,
    required this.chatRoomId,
    required this.senderId,
    required this.messageType,
    required this.content,
    this.fileUrl,
    required this.isEdited,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts snake_case message type from backend to enum
  static MessageTypeModel _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageTypeModel.text;
      case 'image':
        return MessageTypeModel.image;
      case 'file':
        return MessageTypeModel.file;
      case 'transaction_update':
        return MessageTypeModel.transactionUpdate;
      case 'system':
        return MessageTypeModel.system;
      default:
        return MessageTypeModel.text; // Fallback to text
    }
  }

  /// Converts enum to snake_case for backend
  static String _messageTypeToString(MessageTypeModel type) {
    switch (type) {
      case MessageTypeModel.text:
        return 'text';
      case MessageTypeModel.image:
        return 'image';
      case MessageTypeModel.file:
        return 'file';
      case MessageTypeModel.transactionUpdate:
        return 'transaction_update';
      case MessageTypeModel.system:
        return 'system';
    }
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle sender field - can be int or object
    int senderId;
    if (json['sender'] is int) {
      senderId = json['sender'] as int;
    } else if (json['sender'] is Map) {
      senderId = json['sender']['user_id'] as int;
    } else {
      throw Exception('Invalid sender format');
    }

    // Handle chat_room field - can be int or object
    int chatRoomId;
    if (json['chat_room'] is int) {
      chatRoomId = json['chat_room'] as int;
    } else if (json['chat_room'] is Map) {
      chatRoomId = json['chat_room']['chat_room_id'] as int;
    } else {
      throw Exception('Invalid chat_room format');
    }

    return MessageModel(
      messageId: json['message_id'] as int,
      chatRoomId: chatRoomId,
      senderId: senderId,
      messageType: _parseMessageType(json['message_type'] as String),
      content: json['content'] as String,
      fileUrl: json['file_url'] as String?,
      isEdited: json['is_edited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'chat_room': chatRoomId,
      'sender': senderId,
      'message_type': _messageTypeToString(messageType),
      'content': content,
      'file_url': fileUrl,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
