import '../repositories/chat_repository.dart';

class UpdateChatRoomWithMessageUseCase {
  final ChatRepository repository;

  UpdateChatRoomWithMessageUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String lastMessage,
    required String messageType,
  }) async {
    return await repository.updateChatRoomWithMessage(
      roomId: roomId,
      lastMessage: lastMessage,
      messageType: messageType,
    );
  }
}