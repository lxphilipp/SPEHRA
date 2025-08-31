import '../repositories/auth_repository.dart';

/// A use case that signs out the current user.
class SignOutUserUseCase {
  final AuthRepository repository;

  SignOutUserUseCase(this.repository);

  /// Executes the use case.
  Future<void> call() async {
    return await repository.signOut();
  }
}