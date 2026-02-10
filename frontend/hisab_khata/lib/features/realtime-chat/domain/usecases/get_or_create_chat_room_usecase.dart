import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case to get or create a chat room with another user.
class GetOrCreateChatRoomUseCase {
  final ChatRepository repository;

  GetOrCreateChatRoomUseCase({required this.repository});

  Future<ChatRoomEntity> call(int otherUserId) async {
    return await repository.getOrCreateChatRoom(otherUserId);
  }
}
