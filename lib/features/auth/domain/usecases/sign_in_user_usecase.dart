import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// A use case that signs in a user.
class SignInUserUseCase {
  final AuthRepository repository;

  SignInUserUseCase(this.repository);

  /// Executes the use case.
  Future<UserEntity?> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for the [SignInUserUseCase].
class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}