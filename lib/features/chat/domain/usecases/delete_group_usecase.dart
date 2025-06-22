import '../repositories/chat_repository.dart';

class DeleteGroupUseCase {
  final ChatRepository repository;
  DeleteGroupUseCase(this.repository);

  Future<void> call({required String groupId}) {
    return repository.deleteGroup(groupId);
  }
}