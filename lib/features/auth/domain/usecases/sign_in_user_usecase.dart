// lib/features/auth/domain/usecases/sign_in_user_usecase.dart
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUserUseCase {
  final AuthRepository repository;

  SignInUserUseCase(this.repository);

  Future<UserEntity?> call(SignInParams params) async {
    // Hier könnte zusätzliche Geschäftslogik stehen, z.B.
    // - Überprüfung, ob E-Mail-Format gültig ist (obwohl das oft im UI passiert)
    // - Logging des Login-Versuchs
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}