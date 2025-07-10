import 'package:equatable/equatable.dart';

/// Abstrakte Basisklasse für alle nachverfolgbaren Aufgabentypen in einer Challenge.
/// Jede Aufgabe hat eine Beschreibung und einen Abschluss-Status.
abstract class TrackableTask extends Equatable {
  final String description;
  final bool isCompleted;

  const TrackableTask({required this.description, this.isCompleted = false});

  @override
  List<Object?> get props => [description, isCompleted];
}

/// Eine einfache Aufgabe, die durch Abhaken erledigt wird.
class CheckboxTask extends TrackableTask {
  const CheckboxTask({required super.description, super.isCompleted});
}

/// Eine Aufgabe, die das Erreichen einer bestimmten Schrittzahl erfordert.
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

/// Eine Aufgabe, die den Besuch eines geografischen Ortes erfordert.
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

/// Eine Aufgabe, die das Hochladen eines Bildes als Beweis erfordert.
class ImageUploadTask extends TrackableTask {
  final String? uploadedImageUrl; // Speichert die URL des hochgeladenen Bildes

  const ImageUploadTask({
    required super.description,
    this.uploadedImageUrl,
    super.isCompleted,
  });

  @override
  List<Object?> get props => [...super.props, uploadedImageUrl];
}