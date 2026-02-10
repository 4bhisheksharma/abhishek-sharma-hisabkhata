import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

/// Implementation of ChatRepository using remote data source.
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatRoomEntity>> getChatRooms() async {
    final chatRooms = await remoteDataSource.getChatRooms();
    return chatRooms;
  }

  @override
  Future<ChatRoomEntity> getOrCreateChatRoom(int otherUserId) async {
    return await remoteDataSource.getOrCreateChatRoom(otherUserId);
  }

  @override
  Future<ChatMessagesResult> getChatMessages(
    int chatRoomId, {
    int? limit,
    int? beforeMessageId,
  }) async {
    final response = await remoteDataSource.getChatMessages(
      chatRoomId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    return ChatMessagesResult(
      messages: response.messages,
      hasMore: response.hasMore,
    );
  }

  @override
  Future<void> markChatRoomAsRead(int chatRoomId) async {
    await remoteDataSource.markChatRoomAsRead(chatRoomId);
  }

  @override
  Future<MessageEntity> sendMessage({
    required int chatRoomId,
    required String content,
    String messageType = 'text',
  }) async {
    return await remoteDataSource.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
      messageType: messageType,
    );
  }
}
