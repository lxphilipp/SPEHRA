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
      currentUserId, // Positionale Übergabe an Repository-Methode
      partnerUserId,
      initialMessage: initialMessage,
    );
  }
}