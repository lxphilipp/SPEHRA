// lib/features/auth/domain/usecases/get_auth_state_changes_usecase.dart
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateChangesUseCase {
  final AuthRepository repository;

  GetAuthStateChangesUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}