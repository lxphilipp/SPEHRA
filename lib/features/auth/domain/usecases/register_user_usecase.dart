// lib/features/auth/domain/usecases/register_user_usecase.dart
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<UserEntity?> call(RegisterParams params) async {
    // Hier könnte zusätzliche Geschäftslogik stehen, z.B.
    // - Passwortkomplexitätsprüfung (clientseitig, zusätzlich zu Firebase-Regeln)
    // - Überprüfung, ob der Benutzername (falls separat vom Namen) bereits vergeben ist (bräuchte anderes Repo)
    return await repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;
  // Ggf. weitere Felder, die bei der Registrierung übergeben werden

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });
}