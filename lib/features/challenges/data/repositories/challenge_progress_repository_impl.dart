import '../../domain/entities/challenge_progress_entity.dart';
import '../../domain/entities/group_challenge_progress_entity.dart';
import '../../domain/entities/task_progress_entity.dart';
import '../../domain/repositories/challenge_progress_repository.dart';
import '../datasources/challenge_progress_remote_datasource.dart';
import '../models/challenge_progress_model.dart';
import '../models/group_challenge_progress_model.dart';
import '../models/task_progress_modell.dart';

class ChallengeProgressRepositoryImpl implements ChallengeProgressRepository {
  final ChallengeProgressRemoteDataSource remoteDataSource;

  ChallengeProgressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createChallengeProgress(ChallengeProgressEntity progress) {
    final model = ChallengeProgressModel.fromEntity(progress);
    return remoteDataSource.createChallengeProgress(model);
  }

  @override
  Future<void> updateTaskState(String progressId, String taskIndex, TaskProgressEntity newState) {
    // Convert the Entity to a Model and then to a Map
    final newStateMap = TaskProgressModel.fromEntity(newState).toMap();
    return remoteDataSource.updateTaskState(progressId, taskIndex, newStateMap);
  }

  @override
  Stream<ChallengeProgressEntity?> watchChallengeProgress(String progressId) {
    return remoteDataSource.watchChallengeProgress(progressId).map((model) {
      return model?.toEntity(); // Wandle den Stream von Models in Entities um
    });
  }
  @override
  Future<void> createGroupProgress(GroupChallengeProgressEntity groupProgress) {
    final model = GroupChallengeProgressModel.fromEntity(groupProgress);
    return remoteDataSource.createGroupProgress(model);
  }

  @override
  Future<GroupChallengeProgressEntity?> getGroupProgress(String inviteId) async {
    final model = await remoteDataSource.getGroupProgress(inviteId);
    return model?.toEntity();
  }

  @override
  Future<void> addParticipantToGroupProgress({required String inviteId, required String userId, required int tasksPerUser}) {
    return remoteDataSource.addParticipantToGroupProgress(
      inviteId: inviteId,
      userId: userId,
      tasksPerUser: tasksPerUser,
    );
  }

  @override
  Future<GroupChallengeProgressEntity?> incrementGroupProgress(String inviteId) async {
    final updatedModel = await remoteDataSource.incrementGroupProgress(inviteId);
    return updatedModel?.toEntity();
  }

  @override
  Future<void> markMilestoneAsAwarded(String inviteId, int milestone) {
    return remoteDataSource.markMilestoneAsAwarded(inviteId: inviteId, milestone: milestone);
  }
  @override
  Stream<List<GroupChallengeProgressEntity>> watchGroupProgressByContextId(String contextId) {
    return remoteDataSource.watchGroupProgressByContextId(contextId).map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }
}
