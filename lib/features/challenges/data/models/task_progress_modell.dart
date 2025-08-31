import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_progress_entity.dart';

/// Represents the data model for task progress.
///
/// This class is used to convert task progress data between Firestore
/// and the domain layer [TaskProgressEntity].
class TaskProgressModel {
  /// Indicates whether the task is completed.
  final bool isCompleted;

  /// The progress value of the task. Can be of any type.
  final dynamic progressValue;

  /// The timestamp when the task was completed. Null if not completed.
  final Timestamp? completedAt;

  /// Creates a [TaskProgressModel].
  ///
  /// [isCompleted] is required.
  /// [progressValue] and [completedAt] are optional.
  TaskProgressModel({
    required this.isCompleted,
    this.progressValue,
    this.completedAt,
  });

  /// Creates a [TaskProgressModel] from a Firestore map.
  ///
  /// The [map] should contain keys 'isCompleted', 'progressValue', and 'completedAt'.
  factory TaskProgressModel.fromMap(Map<String, dynamic> map) {
    return TaskProgressModel(
      isCompleted: map['isCompleted'] ?? false,
      progressValue: map['progressValue'],
      completedAt: map['completedAt'] as Timestamp?,
    );
  }

  /// Converts this [TaskProgressModel] to a Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'isCompleted': isCompleted,
      'progressValue': progressValue,
      'completedAt': completedAt,
    };
  }

  /// Creates a [TaskProgressModel] from a [TaskProgressEntity].
  factory TaskProgressModel.fromEntity(TaskProgressEntity entity) {
    return TaskProgressModel(
      isCompleted: entity.isCompleted,
      progressValue: entity.progressValue,
      completedAt: entity.completedAt != null ? Timestamp.fromDate(entity.completedAt!) : null,
    );
  }

  /// Converts this [TaskProgressModel] to a [TaskProgressEntity].
  TaskProgressEntity toEntity() {
    return TaskProgressEntity(
      isCompleted: isCompleted,
      progressValue: progressValue,
      completedAt: completedAt?.toDate(),
    );
  }
}
