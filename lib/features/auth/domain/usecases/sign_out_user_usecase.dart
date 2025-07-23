import '../repositories/auth_repository.dart';

class SignOutUserUseCase {
  final AuthRepository repository;

  SignOutUserUseCase(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}