import '../repositories/chat_repository.dart';

/// Use case to get messages for a chat room with pagination.
class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase({required this.repository});

  Future<ChatMessagesResult> call(
    int chatRoomId, {
    int? limit,
    int? beforeMessageId,
  }) async {
    return await repository.getChatMessages(
      chatRoomId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );
  }
}
