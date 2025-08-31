import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../entities/trackable_task.dart';
import '../repositories/device_tracking_repository.dart';
import 'update_task_progress_usecase.dart';

/// Use case for verifying if the user is at the location specified by a task.
///
/// This use case checks the user's current location against the target location
/// defined in a [LocationVisitTask]. If the user is within the specified radius
/// of the target location, it updates the task progress.
class VerifyLocationForTaskUseCase {
  final DeviceTrackingRepository _deviceTrackingRepository;
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;

  /// Creates a [VerifyLocationForTaskUseCase].
  ///
  /// Requires a [DeviceTrackingRepository] to access location services and an
  /// [UpdateTaskProgressUseCase] to update task progress.
  VerifyLocationForTaskUseCase(this._deviceTrackingRepository, this._updateTaskProgressUseCase);

  /// Executes the use case to verify the user's location for a given task.
  ///
  /// [params] The parameters required to verify the location, including the
  /// progress ID, task index, and task definition.
  ///
  /// Returns `true` if the user is at the target location and the task progress
  /// was successfully updated, `false` otherwise.
  Future<bool> call(VerifyLocationParams params) async {
    try {
      final targetTask = params.taskDefinition as LocationVisitTask;
      final targetLocation = LatLng(targetTask.latitude, targetTask.longitude);

      // Now uses the abstract method of the repository
      final isAtLocation = await _deviceTrackingRepository.isUserAtLocation(
          targetLocation,
          targetTask.radius
      );

      // 2. If successful, call the Update-UseCase
      if (isAtLocation) {
        await _updateTaskProgressUseCase(UpdateTaskProgressParams(
          progressId: params.progressId,
          taskIndex: params.taskIndex,
          isCompleted: true,
          newValue: "Location confirmed on ${DateTime.now()}",
        ));
      }
      return isAtLocation;

    } catch (e) {
      // Error handling
      return false;
    }
  }
}

/// Parameters for the [VerifyLocationForTaskUseCase].
class VerifyLocationParams extends Equatable {
  /// The ID of the challenge progress.
  final String progressId;
  /// The index of the task within the challenge.
  final int taskIndex;
  /// The definition of the trackable task.
  final TrackableTask taskDefinition;

  /// Creates [VerifyLocationParams].
  const VerifyLocationParams({
    required this.progressId,
    required this.taskIndex,
    required this.taskDefinition,
  });

  @override
  List<Object?> get props => [progressId, taskIndex, taskDefinition];
}

// Addition in GeolocationService:
// class GeolocationService {
//   ...
//   Future<bool> isUserAtLocation(LatLng target, double radius) async { ... }
// }