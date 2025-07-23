import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfileEntity?> call(String userId) async {
    if (userId.isEmpty) return null; // Einfache Validierung
    return await repository.getUserProfile(userId);
  }
}