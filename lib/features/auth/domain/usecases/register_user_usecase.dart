import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<UserEntity?> call(RegisterParams params) async {
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