import '../entities/chat_user_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatUserByIdUseCase {
  final ChatRepository repository;

  GetChatUserByIdUseCase(this.repository);

  Future<ChatUserEntity?> call({required String userId}) async {
    return await repository.getChatUserById(userId);
  }
}