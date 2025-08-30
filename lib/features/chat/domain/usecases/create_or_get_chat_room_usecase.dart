import '../../domain/entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class CreateOrGetChatRoomUseCase {
  final ChatRepository repository;

  CreateOrGetChatRoomUseCase(this.repository);

  Future<String?> call({
    required String currentUserId,
    required String partnerUserId,
    MessageEntity? initialMessage,
  }) async {
    return await repository.createOrGetChatRoom(
      currentUserId,
      partnerUserId,
      initialMessage: initialMessage,
    );
  }
}