import '../repositories/chat_repository.dart';

class MarkMessageAsReadUseCase {
  final ChatRepository repository;

  MarkMessageAsReadUseCase(this.repository);

  Future<void> call({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
    required String readerUserId,
  }) async {
    return await repository.markMessageAsRead(
      contextId: contextId,
      messageId: messageId,
      isGroupMessage: isGroupMessage,
      readerUserId: readerUserId,
    );
  }
}