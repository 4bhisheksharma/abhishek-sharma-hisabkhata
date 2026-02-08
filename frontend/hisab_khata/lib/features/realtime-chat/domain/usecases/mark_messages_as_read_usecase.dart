import '../repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<bool> call({required int chatRoomId}) async {
    if (chatRoomId <= 0) {
      throw Exception('Invalid chat room ID');
    }

    return await repository.markMessagesAsRead(chatRoomId: chatRoomId);
  }
}
