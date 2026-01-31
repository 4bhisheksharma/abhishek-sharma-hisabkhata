import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<MessageEntity> call({
    required int chatRoomId,
    required String content,
    MessageType messageType = MessageType.text,
    String? fileUrl,
  }) async {
    // Validate inputs
    if (content.trim().isEmpty && messageType == MessageType.text) {
      throw Exception('Message content cannot be empty');
    }
    if (chatRoomId <= 0) {
      throw Exception('Invalid chat room ID');
    }

    // Call repository
    return await repository.sendMessage(
      chatRoomId: chatRoomId,
      content: content.trim(),
      messageType: messageType,
      fileUrl: fileUrl,
    );
  }
}
