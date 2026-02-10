import '../entities/chat_room_entity.dart';
import '../entities/message_entity.dart';

/// Repository interface for chat operations.
abstract class ChatRepository {
  /// Get all chat rooms for current user.
  Future<List<ChatRoomEntity>> getChatRooms();

  /// Get or create a chat room with another user.
  Future<ChatRoomEntity> getOrCreateChatRoom(int otherUserId);

  /// Get messages for a chat room with pagination.
  Future<ChatMessagesResult> getChatMessages(
    int chatRoomId, {
    int? limit,
    int? beforeMessageId,
  });

  /// Mark all messages in a chat room as read.
  Future<void> markChatRoomAsRead(int chatRoomId);

  /// Send a message via REST API (fallback when WebSocket unavailable).
  Future<MessageEntity> sendMessage({
    required int chatRoomId,
    required String content,
    String messageType = 'text',
  });
}

/// Result wrapper for paginated messages.
class ChatMessagesResult {
  final List<MessageEntity> messages;
  final bool hasMore;

  ChatMessagesResult({
    required this.messages,
    required this.hasMore,
  });
}
