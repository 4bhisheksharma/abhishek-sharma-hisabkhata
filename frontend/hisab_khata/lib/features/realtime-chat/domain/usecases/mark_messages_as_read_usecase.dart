import '../repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<bool> call({
    required int chatRoomId,
    required List<int> messageIds,
  }) async {
    if (chatRoomId <= 0) {
      throw Exception('Invalid chat room ID');
    }
    if (messageIds.isEmpty) {
      throw Exception('Message IDs list cannot be empty');
    }

    return await repository.markMessagesAsRead(
      chatRoomId: chatRoomId,
      messageIds: messageIds,
    );
  }
}
