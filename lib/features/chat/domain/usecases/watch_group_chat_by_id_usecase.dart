import '../entities/group_chat_entity.dart';
import '../repositories/chat_repository.dart';

class WatchGroupChatByIdUseCase {
  final ChatRepository repository;

  WatchGroupChatByIdUseCase(this.repository);

  Stream<GroupChatEntity?> call({required String groupId}) {
    return repository.watchGroupChatById(groupId: groupId);
  }
}