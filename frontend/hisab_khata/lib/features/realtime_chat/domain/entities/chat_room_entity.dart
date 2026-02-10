import 'package:equatable/equatable.dart';
import 'chat_user_entity.dart';

/// Entity representing a last message preview in a chat room.
class LastMessageEntity extends Equatable {
  final String content;
  final int senderId;
  final String senderName;
  final DateTime createdAt;
  final bool isRead;

  const LastMessageEntity({
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [content, senderId, senderName, createdAt, isRead];
}

/// Entity representing a chat room.
class ChatRoomEntity extends Equatable {
  final int chatRoomId;
  final ChatUserEntity participantOne;
  final ChatUserEntity participantTwo;
  final ChatUserEntity? otherParticipant;
  final LastMessageEntity? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const ChatRoomEntity({
    required this.chatRoomId,
    required this.participantOne,
    required this.participantTwo,
    this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  /// Get display name for the chat room (other participant's name).
  /// Returns business name for businesses, full name for others.
  String getDisplayName(int currentUserId) {
    if (otherParticipant != null) {
      return otherParticipant!.displayName;
    }
    final other = participantOne.userId == currentUserId
        ? participantTwo
        : participantOne;
    return other.displayName;
  }

  /// Get the other participant's info.
  ChatUserEntity getOtherParticipant(int currentUserId) {
    if (otherParticipant != null) {
      return otherParticipant!;
    }
    return participantOne.userId == currentUserId
        ? participantTwo
        : participantOne;
  }

  /// Check if user is a participant.
  bool isParticipant(int userId) {
    return participantOne.userId == userId || participantTwo.userId == userId;
  }

  @override
  List<Object?> get props => [
    chatRoomId,
    participantOne,
    participantTwo,
    otherParticipant,
    lastMessage,
    unreadCount,
    lastMessageAt,
    createdAt,
  ];
}
