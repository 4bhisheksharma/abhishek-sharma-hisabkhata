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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] as int,
      chatRoomId: json['chat_room'] as int,
      senderId: json['sender'] as int,
      messageType: MessageTypeModel.values.firstWhere(
        (e) => e.name == json['message_type'] as String,
      ),
      content: json['content'] as String,
      fileUrl: json['file_url'] as String?,
      isEdited: json['is_edited'] as bool,
      isDeleted: json['is_deleted'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'chat_room': chatRoomId,
      'sender': senderId,
      'message_type': messageType.name,
      'content': content,
      'file_url': fileUrl,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
