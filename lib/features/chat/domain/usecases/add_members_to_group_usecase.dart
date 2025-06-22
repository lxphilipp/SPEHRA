import '../repositories/chat_repository.dart';

class AddMembersToGroupUseCase {
  final ChatRepository repository;

  AddMembersToGroupUseCase(this.repository);

  Future<void> call({
    required String groupId,
    required List<String> memberIdsToAdd,
  }) async {
    return await repository.addMembersToGroup(groupId, memberIdsToAdd);
  }
}