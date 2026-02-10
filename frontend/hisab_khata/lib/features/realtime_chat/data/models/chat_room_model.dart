import '../../domain/entities/chat_room_entity.dart';
import 'chat_user_model.dart';

/// Model for last message data.
class LastMessageModel extends LastMessageEntity {
  const LastMessageModel({
    required super.content,
    required super.senderId,
    required super.senderName,
    required super.createdAt,
    required super.isRead,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      content: json['content'] as String,
      senderId: json['sender_id'] as int,
      senderName: json['sender_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

/// Model for chat room data from API response.
class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.chatRoomId,
    required super.participantOne,
    required super.participantTwo,
    super.otherParticipant,
    super.lastMessage,
    required super.unreadCount,
    super.lastMessageAt,
    required super.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomId: json['chat_room_id'] as int,
      participantOne: ChatUserModel.fromJson(
        json['participant_one'] as Map<String, dynamic>,
      ),
      participantTwo: ChatUserModel.fromJson(
        json['participant_two'] as Map<String, dynamic>,
      ),
      otherParticipant: json['other_participant'] != null
          ? ChatUserModel.fromJson(
              json['other_participant'] as Map<String, dynamic>,
            )
          : null,
      lastMessage: json['last_message'] != null
          ? LastMessageModel.fromJson(
              json['last_message'] as Map<String, dynamic>,
            )
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'unread_count': unreadCount,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
