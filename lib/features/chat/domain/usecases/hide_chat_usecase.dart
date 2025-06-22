import '../repositories/chat_repository.dart';

class HideChatUseCase {
  final ChatRepository repository;
  HideChatUseCase(this.repository);

  Future<void> call({required String roomId, required String userId}) {
    return repository.hideChatForUser(roomId, userId);
  }
}