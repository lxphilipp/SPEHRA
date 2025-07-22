import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/image_picker_service.dart';
import 'update_task_progress_usecase.dart';

class SelectImageForTaskUseCase {
  final ImagePickerService _imagePickerService;
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;

  SelectImageForTaskUseCase(this._imagePickerService, this._updateTaskProgressUseCase);

  Future<String?> call(SelectImageParams params) async {
    try {
      final File? imageFile = await _imagePickerService.pickImageFromGallery();

      if (imageFile != null) {
        await _updateTaskProgressUseCase(UpdateTaskProgressParams(
          progressId: params.progressId,
          taskIndex: params.taskIndex,
          isCompleted: true,
          newValue: imageFile.path,
        ));
        return imageFile.path;
      }
      return null;
    } catch (e) {
      AppLogger.error("Error in SelectImageForTaskUseCase: $e");
      return null;
    }
  }
}

class SelectImageParams extends Equatable {
  final String progressId;
  final int taskIndex;

  const SelectImageParams({required this.progressId, required this.taskIndex});

  @override
  List<Object?> get props => [progressId, taskIndex];
}