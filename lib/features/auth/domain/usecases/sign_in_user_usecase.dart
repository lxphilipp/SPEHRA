import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUserUseCase {
  final AuthRepository repository;

  SignInUserUseCase(this.repository);

  Future<UserEntity?> call(SignInParams params) async {
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