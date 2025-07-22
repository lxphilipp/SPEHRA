import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_logger.dart';

/// An abstract contract that defines what the service must be able to do.
/// The domain layer will only know this interface.
abstract class ImagePickerService {
  Future<File?> pickImageFromGallery();
}

/// The concrete implementation that uses the image_picker package.
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress images slightly
        maxWidth: 1024,  // Resize images for display
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null; // User cancelled selection
    } catch (e) {
      // Error opening gallery or with permissions
      AppLogger.error("ImagePickerService Error: $e");
      rethrow; // Re-throw error so the Use Case can handle it
    }
  }
}