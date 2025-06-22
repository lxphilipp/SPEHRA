// lib/features/chat/domain/usecases/update_group_chat_with_message_usecase.dart
import '../repositories/chat_repository.dart'; // Beispiel

class UpdateGroupChatWithMessageUseCase {
  final ChatRepository repository;
  UpdateGroupChatWithMessageUseCase(this.repository);
  Future<void> call({required String groupId, required String lastMessage, required String messageType}) {
    return repository.updateGroupChatWithMessage(groupId: groupId, lastMessage: lastMessage, messageType: messageType);
  }
}