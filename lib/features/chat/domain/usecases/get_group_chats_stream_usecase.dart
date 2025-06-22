import '../entities/group_chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetGroupChatsStreamUseCase {
  final ChatRepository repository;

  GetGroupChatsStreamUseCase(this.repository);

  Stream<List<GroupChatEntity>> call({required String currentUserId}) {
    return repository.getGroupChatsStream(currentUserId);
  }
}