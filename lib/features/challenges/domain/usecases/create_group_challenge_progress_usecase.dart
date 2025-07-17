import '../entities/challenge_entity.dart';
import '../entities/group_challenge_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

class CreateGroupChallengeProgressUseCase {
  final ChallengeProgressRepository _repository;
  static const int minParticipantsForGroupChallenge = 3;

  CreateGroupChallengeProgressUseCase(this._repository);

  Future<void> call({
    required String inviteId,
    required String contextId, // Hinzugefügt
    required ChallengeEntity challenge,
    required List<String> initialParticipantIds,
  }) async {
    final newGroupProgress = GroupChallengeProgressEntity(
      id: inviteId,
      challengeId: challenge.id,
      contextId: contextId, // Hinzugefügt
      participantIds: initialParticipantIds,
      totalTasksRequired: challenge.tasks.length * initialParticipantIds.length,
      completedTasksCount: 0,
      unlockedMilestones: [],
      createdAt: DateTime.now(),
    );

    await _repository.createGroupProgress(newGroupProgress);
  }
}