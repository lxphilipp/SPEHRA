import 'package:equatable/equatable.dart';
import 'update_task_progress_usecase.dart'; // We use our existing Use Case

class ToggleCheckboxTaskUseCase {
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;

  ToggleCheckboxTaskUseCase(this._updateTaskProgressUseCase);

  Future<void> call(ToggleCheckboxParams params) async {
    await _updateTaskProgressUseCase(UpdateTaskProgressParams(
      progressId: params.progressId,
      taskIndex: params.taskIndex,
      isCompleted: params.isCompleted,
      newValue: null,
    ));
  }
}

class ToggleCheckboxParams extends Equatable {
  final String progressId;
  final int taskIndex;
  final bool isCompleted;

  const ToggleCheckboxParams({
    required this.progressId,
    required this.taskIndex,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [progressId, taskIndex, isCompleted];
}