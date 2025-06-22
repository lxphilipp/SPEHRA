import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

class WatchChatRoomByIdUseCase {
  final ChatRepository repository;
  WatchChatRoomByIdUseCase(this.repository);

  Stream<ChatRoomEntity?> call({required String roomId}) {
    return repository.watchChatRoomById(roomId);
  }
}