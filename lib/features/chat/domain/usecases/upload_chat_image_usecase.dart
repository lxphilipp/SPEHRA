import 'dart:io';
import '../repositories/chat_repository.dart';

class UploadChatImageUseCase {
  final ChatRepository repository;

  UploadChatImageUseCase(this.repository);

  Future<String?> call({
    required File imageFile,
    required String contextId,
    required String uploaderUserId,
  }) async {
    return await repository.uploadChatImage(
      imageFile: imageFile,
      contextId: contextId,
      uploaderUserId: uploaderUserId,
    );
  }
}