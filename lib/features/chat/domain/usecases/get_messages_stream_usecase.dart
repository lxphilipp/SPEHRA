import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesStreamUseCase {
  final ChatRepository repository;

  GetMessagesStreamUseCase(this.repository);

  Stream<List<MessageEntity>> call({required String roomId}) {
    return repository.getMessagesStream(roomId);
  }
}