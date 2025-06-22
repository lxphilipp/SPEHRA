import '../repositories/chat_repository.dart';

class RemoveMemberFromGroupUseCase {
  final ChatRepository repository;

  RemoveMemberFromGroupUseCase(this.repository);

  Future<void> call({
    required String groupId,
    required String memberIdToRemove,
  }) async {
    return await repository.removeMemberFromGroup(groupId, memberIdToRemove);
  }
}