import '../entities/challenge_progress_entity.dart';
import '../entities/task_progress_entity.dart';

abstract class ChallengeProgressRepository {
  Stream<ChallengeProgressEntity?> watchChallengeProgress(String progressId);
  Future<void> createChallengeProgress(ChallengeProgressEntity progress);
  Future<void> updateTaskState(String progressId, String taskIndex, TaskProgressEntity newState);
}