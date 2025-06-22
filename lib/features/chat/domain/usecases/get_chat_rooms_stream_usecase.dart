import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatRoomsStreamUseCase {
  final ChatRepository repository;

  GetChatRoomsStreamUseCase(this.repository);

  Stream<List<ChatRoomEntity>> call({required String currentUserId}) {
    return repository.getChatRoomsStream(currentUserId);
  }
}