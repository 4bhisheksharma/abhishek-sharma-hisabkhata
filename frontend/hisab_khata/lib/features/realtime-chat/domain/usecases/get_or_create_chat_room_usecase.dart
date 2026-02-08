import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateChatRoomUseCase {
  final ChatRepository repository;

  GetOrCreateChatRoomUseCase(this.repository);

  Future<ChatRoomEntity> call(int relationshipId) async {
    if (relationshipId <= 0) {
      throw Exception('Invalid relationship ID');
    }

    return await repository.getOrCreateChatRoom(relationshipId);
  }
}
