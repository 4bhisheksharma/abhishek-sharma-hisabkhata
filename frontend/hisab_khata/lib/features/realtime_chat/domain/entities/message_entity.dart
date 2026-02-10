import 'package:equatable/equatable.dart';
import 'chat_user_entity.dart';

/// Entity representing a chat message.
class MessageEntity extends Equatable {
  final int messageId;
  final int chatRoomId;
  final ChatUserEntity sender;
  final String content;
  final String messageType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageEntity({
    required this.messageId,
    required this.chatRoomId,
    required this.sender,
    required this.content,
    required this.messageType,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  /// Check if message is from the current user.
  bool isFromUser(int currentUserId) => sender.userId == currentUserId;

  @override
  List<Object?> get props => [
        messageId,
        chatRoomId,
        sender,
        content,
        messageType,
        isRead,
        readAt,
        createdAt,
      ];
}
