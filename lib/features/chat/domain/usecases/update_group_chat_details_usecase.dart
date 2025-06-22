import '../entities/group_chat_entity.dart';
import '../repositories/chat_repository.dart';

class UpdateGroupChatDetailsUseCase {
  final ChatRepository repository;

  UpdateGroupChatDetailsUseCase(this.repository);

  Future<void> call({required GroupChatEntity groupChatEntity}) async {
    return await repository.updateGroupChatDetails(groupChatEntity);
  }
}