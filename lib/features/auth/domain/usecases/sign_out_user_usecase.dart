// lib/features/auth/domain/usecases/sign_out_user_usecase.dart
import '../repositories/auth_repository.dart';

class SignOutUserUseCase {
  final AuthRepository repository;

  SignOutUserUseCase(this.repository);

  Future<void> call() async {
    // Hier könnte zusätzliche Geschäftslogik stehen, z.B.
    // - Löschen lokaler Benutzerdaten/Cache beim Logout
    // - Senden eines "User logged out"-Events an Analytics
    return await repository.signOut();
  }
}