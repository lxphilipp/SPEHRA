import 'package:equatable/equatable.dart';

/// Represents the progress of a task within a challenge.
class TaskProgressEntity extends Equatable {
  /// Whether the task is completed.
  final bool isCompleted;

  /// The current progress value of the task.
  ///
  /// This can be of any type depending on the task's requirements
  /// (e.g., int for count, double for percentage, String for text input).
  final dynamic progressValue;

  /// The date and time when the task was completed.
  ///
  /// This is `null` if the task is not yet completed.
  final DateTime? completedAt;

  /// Creates a [TaskProgressEntity].
  ///
  /// [isCompleted] defaults to `false`.
  /// [progressValue] and [completedAt] are optional.
  const TaskProgressEntity({
    this.isCompleted = false,
    this.progressValue,
    this.completedAt,
  });

  @override
  List<Object?> get props => [isCompleted, progressValue, completedAt];

  /// Creates a copy of this [TaskProgressEntity] but with the given fields
  /// replaced with the new values.
  TaskProgressEntity copyWith({
    bool? isCompleted,
    dynamic progressValue,
    DateTime? completedAt,
  }) {
    return TaskProgressEntity(
      isCompleted: isCompleted ?? this.isCompleted,
      progressValue: progressValue ?? this.progressValue,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}