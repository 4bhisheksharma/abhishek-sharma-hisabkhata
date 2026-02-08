import '../entities/chat_room_entity.dart';
import '../entities/message_entity.dart';
import '../entities/message_status_entity.dart';

abstract class ChatRepository {
  /// Gets all chat rooms for the current user
  /// Returns a stream of chat rooms that updates in real-time
  Stream<List<ChatRoomEntity>> getChatRooms();

  /// Gets messages for a specific chat room
  /// Returns a stream of messages that updates in real-time
  Stream<List<MessageEntity>> getMessages(int chatRoomId);

  /// Sends a new message to a chat room
  /// Returns the sent message entity
  Future<MessageEntity> sendMessage({
    required int chatRoomId,
    required String content,
    required MessageType messageType,
    String? fileUrl,
  });

  /// Marks messages as read for the current user
  /// Returns success status
  Future<bool> markMessagesAsRead({required int chatRoomId});

  /// Gets message statuses for messages in a chat room
  /// Returns a stream of message statuses
  Stream<List<MessageStatusEntity>> getMessageStatuses(int chatRoomId);

  /// Creates or gets existing chat room for a relationship
  /// Returns the chat room entity
  Future<ChatRoomEntity> getOrCreateChatRoom(int relationshipId);
}
