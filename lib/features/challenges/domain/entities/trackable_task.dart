import 'package:equatable/equatable.dart';

/// Abstract base class for all trackable task types in a Challenge.
/// Each task has a description and a completion status.
abstract class TrackableTask extends Equatable {
  final String description;
  final bool isCompleted;

  const TrackableTask({required this.description, this.isCompleted = false});

  @override
  List<Object?> get props => [description, isCompleted];
}

/// A simple task that is completed by checking a box.
class CheckboxTask extends TrackableTask {
  const CheckboxTask({required super.description, super.isCompleted});
}

/// A task that requires reaching a certain number of steps.
class StepCounterTask extends TrackableTask {
  final int targetSteps;

  const StepCounterTask({
    required super.description,
    required this.targetSteps,
    super.isCompleted,
  });

  @override
  List<Object?> get props => [...super.props, targetSteps];
}

/// A task that requires visiting a geographical location.
class LocationVisitTask extends TrackableTask {
  final double latitude;
  final double longitude;
  final double radius;

  const LocationVisitTask({
    required super.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    super.isCompleted,
  });

  @override
  List<Object?> get props => [...super.props, latitude, longitude, radius];
}

/// A task that requires uploading an image as proof.
class ImageUploadTask extends TrackableTask {
  final String? uploadedImageUrl; // Stores the URL of the uploaded image

  const ImageUploadTask({
    required super.description,
    this.uploadedImageUrl,
    super.isCompleted,
  });

  @override
  List<Object?> get props => [...super.props, uploadedImageUrl];
}