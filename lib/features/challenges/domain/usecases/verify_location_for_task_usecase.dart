import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../entities/trackable_task.dart';
import '../repositories/device_tracking_repository.dart';
import 'update_task_progress_usecase.dart';

class VerifyLocationForTaskUseCase {
  final DeviceTrackingRepository _deviceTrackingRepository;
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;

  VerifyLocationForTaskUseCase(this._deviceTrackingRepository, this._updateTaskProgressUseCase);

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

class VerifyLocationParams extends Equatable {
  final String progressId;
  final int taskIndex;
  final TrackableTask taskDefinition;

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