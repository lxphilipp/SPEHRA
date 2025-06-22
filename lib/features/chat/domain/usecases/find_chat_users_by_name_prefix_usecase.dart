import '../entities/chat_user_entity.dart';
import '../repositories/chat_repository.dart';

class FindChatUsersByNamePrefixUseCase {
  final ChatRepository repository;

  FindChatUsersByNamePrefixUseCase(this.repository);

  Future<List<ChatUserEntity>> call({required String namePrefix, List<String> excludeIds = const []}) async {
    return await repository.findChatUsersByNamePrefix(namePrefix, excludeIds: excludeIds);
  }
}