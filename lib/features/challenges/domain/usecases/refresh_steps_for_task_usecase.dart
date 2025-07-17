import 'package:equatable/equatable.dart';
import '../entities/challenge_progress_entity.dart';
import '../entities/trackable_task.dart';
import '../repositories/device_tracking_repository.dart';
import 'update_task_progress_usecase.dart';

class RefreshStepsForTaskUseCase {
  final DeviceTrackingRepository _deviceTrackingRepository;
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;

  RefreshStepsForTaskUseCase(this._deviceTrackingRepository, this._updateTaskProgressUseCase);

  Future<void> call(RefreshStepsParams params) async {
    try {
      // 1. Get current steps via the abstract repository
      final stepsToday = await _deviceTrackingRepository.getTodaysSteps();

      // 2. Get the task definition to know the target
      final taskDefinition = params.taskDefinition as StepCounterTask;
      final bool isCompleted = stepsToday >= taskDefinition.targetSteps;

      // 3. Call the update specialist to save the progress
      await _updateTaskProgressUseCase(UpdateTaskProgressParams(
        progressId: params.progressId,
        taskIndex: params.taskIndex,
        isCompleted: isCompleted,
        newValue: stepsToday,
      ));

    } catch (e) {
      // Error handling, e.g., logging
      print("Error in RefreshStepsForTaskUseCase: $e");
      // Optional: Re-throw exception so the Provider can catch it
      rethrow;
    }
  }
}

class RefreshStepsParams extends Equatable {
  final String progressId;
  final int taskIndex;
  final TrackableTask taskDefinition;

  const RefreshStepsParams({
    required this.progressId,
    required this.taskIndex,
    required this.taskDefinition,
  });

  @override
  List<Object?> get props => [progressId, taskIndex, taskDefinition];
}