import '../repositories/chat_repository.dart';

class SetChatClearedTimestampUseCase {
  final ChatRepository repository;
  SetChatClearedTimestampUseCase(this.repository);

  Future<void> call({required String roomId, required String userId}) {
    return repository.setChatClearedTimestamp(roomId, userId);
  }
}