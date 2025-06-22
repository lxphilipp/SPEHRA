import 'dart:io'; // Für File
import '../repositories/user_profile_repository.dart';

class UploadProfileImageUseCase {
  final UserProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<String?> call(UploadProfileImageParams params) async {
    if (params.userId.isEmpty) return null;
    // Hier könnte Logik stehen, um z.B. die Bildgröße oder den Typ zu prüfen,
    // bevor es ans Repository geht.
    return await repository.uploadAndUpdateProfileImage(
      userId: params.userId,
      imageFile: params.imageFile,
      oldImageUrl: params.oldImageUrl,
    );
  }
}

// Parameter-Klasse
class UploadProfileImageParams {
  final String userId;
  final File imageFile;
  final String? oldImageUrl;

  UploadProfileImageParams({
    required this.userId,
    required this.imageFile,
    this.oldImageUrl,
  });
}