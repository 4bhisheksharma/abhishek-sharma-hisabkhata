import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case to get all chat rooms for current user.
class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase({required this.repository});

  Future<List<ChatRoomEntity>> call() async {
    return await repository.getChatRooms();
  }
}
