import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// A use case that gets the authentication state changes.
class GetAuthStateChangesUseCase {
  final AuthRepository repository;

  GetAuthStateChangesUseCase(this.repository);

  /// Executes the use case.
  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}