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
      // 1. Hol die aktuellen Schritte über das abstrakte Repository
      final stepsToday = await _deviceTrackingRepository.getTodaysSteps();

      // 2. Hol die Aufgaben-Definition, um das Ziel zu kennen
      final taskDefinition = params.taskDefinition as StepCounterTask;
      final bool isCompleted = stepsToday >= taskDefinition.targetSteps;

      // 3. Rufe den Update-Spezialisten auf, um den Fortschritt zu speichern
      await _updateTaskProgressUseCase(UpdateTaskProgressParams(
        progressId: params.progressId,
        taskIndex: params.taskIndex,
        isCompleted: isCompleted,
        newValue: stepsToday,
      ));

    } catch (e) {
      // Fehlerbehandlung, z.B. Logging
      print("Fehler im RefreshStepsForTaskUseCase: $e");
      // Optional: Exception weiterwerfen, damit der Provider sie fangen kann
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