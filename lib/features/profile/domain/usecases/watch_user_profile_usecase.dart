import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class WatchUserProfileUseCase {
  final UserProfileRepository repository;

  WatchUserProfileUseCase(this.repository);

  // Nimmt die userId als Parameter
  Stream<UserProfileEntity?> call(String userId) {
    if (userId.isEmpty) return Stream.value(null); // Einfache Validierung
    return repository.watchUserProfile(userId);
  }
}