import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call({
    required MessageEntity message,
    required String contextId,
    required bool isGroupMessage,
  }) async {
    return await repository.sendMessage(
      message: message,
      contextId: contextId,
      isGroupMessage: isGroupMessage,
    );
  }
}