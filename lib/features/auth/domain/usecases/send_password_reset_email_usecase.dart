import '../repositories/auth_repository.dart';

/// A use case that sends a password reset email.
class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  /// Executes the use case.
  Future<bool> call(String email) async {
    if (email.isEmpty /* || !isValidEmail(email) */) {
      return false;
    }
    return await repository.sendPasswordResetEmail(email: email);
  }
}