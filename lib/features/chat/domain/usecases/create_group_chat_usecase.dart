import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class CreateGroupChatUseCase {
  final ChatRepository repository;

  CreateGroupChatUseCase(this.repository);

  Future<String?> call({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    required String currentUserId,
    String? imageUrl,
    MessageEntity? initialMessage,
  }) async {
    return await repository.createGroupChat(
      name: name,
      memberIds: memberIds,
      adminIds: adminIds,
      currentUserId: currentUserId,
      imageUrl: imageUrl,
      initialMessage: initialMessage,
    );
  }
}