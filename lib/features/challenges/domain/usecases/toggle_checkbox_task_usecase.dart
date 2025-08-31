/// {@template toggle_checkbox_task_usecase}
/// Use case for toggling the completion status of a checkbox task.
/// {@endtemplate}
import 'package:equatable/equatable.dart';
import 'update_task_progress_usecase.dart';

/// {@template toggle_checkbox_task_usecase}
/// Use case for toggling the completion status of a checkbox task.
///
/// This use case relies on the [UpdateTaskProgressUseCase] to update the
/// task's progress.
/// {@endtemplate}
class ToggleCheckboxTaskUseCase {
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;

  /// {@macro toggle_checkbox_task_usecase}
  ToggleCheckboxTaskUseCase(this._updateTaskProgressUseCase);

  /// Executes the use case to toggle the checkbox task status.
  ///
  /// Takes [ToggleCheckboxParams] as input, which specifies the progress ID,
  /// task index, and the new completion status.
  Future<void> call(ToggleCheckboxParams params) async {
    await _updateTaskProgressUseCase(UpdateTaskProgressParams(
      progressId: params.progressId,
      taskIndex: params.taskIndex,
      isCompleted: params.isCompleted,
      newValue: null,
    ));
  }
}

/// {@template toggle_checkbox_params}
/// Parameters for the [ToggleCheckboxTaskUseCase].
/// {@endtemplate}
class ToggleCheckboxParams extends Equatable {
  /// The ID of the challenge progress.
  final String progressId;

  /// The index of the task within the challenge.
  final int taskIndex;

  /// The new completion status of the checkbox task.
  final bool isCompleted;

  /// {@macro toggle_checkbox_params}
  const ToggleCheckboxParams({
    required this.progressId,
    required this.taskIndex,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [progressId, taskIndex, isCompleted];
}
