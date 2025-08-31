import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// A use case that registers a new user.
class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  /// Executes the use case.
  Future<UserEntity?> call(RegisterParams params) async {
    return await repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

/// Parameters for the [RegisterUserUseCase].
class RegisterParams {
  final String email;
  final String password;
  final String name;
  // Possibly other fields that are passed during registration

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });
}