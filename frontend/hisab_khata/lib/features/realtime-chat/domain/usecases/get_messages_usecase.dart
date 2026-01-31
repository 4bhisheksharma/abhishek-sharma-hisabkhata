import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call({required int chatRoomId}) {
    if (chatRoomId <= 0) {
      throw Exception('Invalid chat room ID');
    }

    return repository.getMessages(chatRoomId);
  }
}
