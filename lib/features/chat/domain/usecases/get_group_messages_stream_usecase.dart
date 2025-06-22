import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetGroupMessagesStreamUseCase {
  final ChatRepository repository;

  GetGroupMessagesStreamUseCase(this.repository);

  Stream<List<MessageEntity>> call({required String groupId}) {
    return repository.getGroupMessagesStream(groupId);
  }
}