import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// A use case that gets the current user.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Executes the use case.
  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}