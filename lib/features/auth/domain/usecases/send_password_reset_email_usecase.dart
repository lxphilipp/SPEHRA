import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<bool> call(String email) async {
    if (email.isEmpty /* || !isValidEmail(email) */) {
      return false;
    }
    return await repository.sendPasswordResetEmail(email: email);
  }
}