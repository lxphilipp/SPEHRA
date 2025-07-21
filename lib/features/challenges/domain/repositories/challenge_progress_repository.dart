import '../entities/challenge_progress_entity.dart';
import '../entities/group_challenge_progress_entity.dart';
import '../entities/task_progress_entity.dart';

abstract class ChallengeProgressRepository {
  Stream<ChallengeProgressEntity?> watchChallengeProgress(String progressId);
  Future<void> createChallengeProgress(ChallengeProgressEntity progress);
  Future<void> updateTaskState(String progressId, String taskIndex, TaskProgressEntity newState);
  Future<void> createGroupProgress(GroupChallengeProgressEntity groupProgress);
  Future<GroupChallengeProgressEntity?> getGroupProgress(String inviteId);
  Future<void> addParticipantToGroupProgress({required String inviteId, required String userId, required int tasksPerUser});
  Future<GroupChallengeProgressEntity?> incrementGroupProgress(String inviteId);
  Future<void> markMilestoneAsAwarded(String inviteId, int milestone);
  Stream<List<GroupChallengeProgressEntity>> watchGroupProgressByContextId(String contextId);
}