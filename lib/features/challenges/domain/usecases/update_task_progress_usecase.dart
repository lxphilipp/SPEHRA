import 'package:equatable/equatable.dart';
import '../entities/task_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

class UpdateTaskProgressUseCase {
  final ChallengeProgressRepository _repository;

  UpdateTaskProgressUseCase(this._repository);

  Future<void> call(UpdateTaskProgressParams params) async {
    // Logic to determine if the task is now completed
    final newState = TaskProgressEntity(
      isCompleted: params.isCompleted,
      progressValue: params.newValue,
      completedAt: params.isCompleted ? DateTime.now() : null,
    );
    await _repository.updateTaskState(params.progressId, params.taskIndex.toString(), newState);
    final individualProgress = await _repository.watchChallengeProgress(params.progressId).first;
    if (individualProgress?.inviteId != null) {
      await _repository.incrementGroupProgress(individualProgress!.inviteId!);
    }
  }
}

class UpdateTaskProgressParams extends Equatable {
  final String progressId;
  final int taskIndex;
  final dynamic newValue;
  final bool isCompleted;

  const UpdateTaskProgressParams({
    required this.progressId,
    required this.taskIndex,
    this.newValue,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [progressId, taskIndex, newValue, isCompleted];
}