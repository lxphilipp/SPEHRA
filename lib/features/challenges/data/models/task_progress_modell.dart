import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/challenge_progress_entity.dart';
import '../../domain/entities/task_progress_entity.dart';

class TaskProgressModel {
  final bool isCompleted;
  final dynamic progressValue;
  final Timestamp? completedAt;

  TaskProgressModel({
    required this.isCompleted,
    this.progressValue,
    this.completedAt,
  });

  factory TaskProgressModel.fromMap(Map<String, dynamic> map) {
    return TaskProgressModel(
      isCompleted: map['isCompleted'] ?? false,
      progressValue: map['progressValue'],
      completedAt: map['completedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isCompleted': isCompleted,
      'progressValue': progressValue,
      'completedAt': completedAt,
    };
  }

  factory TaskProgressModel.fromEntity(TaskProgressEntity entity) {
    return TaskProgressModel(
      isCompleted: entity.isCompleted,
      progressValue: entity.progressValue,
      completedAt: entity.completedAt != null ? Timestamp.fromDate(entity.completedAt!) : null,
    );
  }

  TaskProgressEntity toEntity() {
    return TaskProgressEntity(
      isCompleted: isCompleted,
      progressValue: progressValue,
      completedAt: completedAt?.toDate(),
    );
  }
}

