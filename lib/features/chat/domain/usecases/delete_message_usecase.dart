import '../repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<void> call({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
  }) async {
    return await repository.deleteMessage(
      contextId: contextId,
      messageId: messageId,
      isGroupMessage: isGroupMessage,
    );
  }
}