import '../entities/chat_user_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatUsersStreamByIdsUseCase {
  final ChatRepository repository;

  GetChatUsersStreamByIdsUseCase(this.repository);

  Stream<List<ChatUserEntity>> call({required List<String> userIds}) {
    return repository.getChatUsersStreamByIds(userIds);
  }
}