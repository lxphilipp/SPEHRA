// lib/features/auth/domain/usecases/send_password_reset_email_usecase.dart
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<bool> call(String email) async {
    if (email.isEmpty /* || !isValidEmail(email) */) { // Simple validation
      return false;
    }
    return await repository.sendPasswordResetEmail(email: email);
  }
}