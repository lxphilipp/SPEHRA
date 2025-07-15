import '../../domain/entities/challenge_progress_entity.dart';
import '../../domain/entities/task_progress_entity.dart';
import '../../domain/repositories/challenge_progress_repository.dart';
import '../datasources/challenge_progress_remote_datasource.dart';
import '../models/challenge_progress_model.dart';
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
    // Wandle die Entity in ein Model und dann in eine Map um
    final newStateMap = TaskProgressModel.fromEntity(newState).toMap();
    return remoteDataSource.updateTaskState(progressId, taskIndex, newStateMap);
  }

  @override
  Stream<ChallengeProgressEntity?> watchChallengeProgress(String progressId) {
    return remoteDataSource.watchChallengeProgress(progressId).map((model) {
      return model?.toEntity(); // Wandle den Stream von Models in Entities um
    });
  }
}