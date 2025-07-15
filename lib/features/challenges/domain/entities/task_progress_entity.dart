import 'package:equatable/equatable.dart';

class TaskProgressEntity extends Equatable {
  final bool isCompleted;
  final dynamic progressValue;
  final DateTime? completedAt;

  const TaskProgressEntity({
    this.isCompleted = false,
    this.progressValue,
    this.completedAt,
  });

  @override
  List<Object?> get props => [isCompleted, progressValue, completedAt];

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