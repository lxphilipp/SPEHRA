// Dieser Use Case würde UserProfileRepository benötigen
import '/features/profile/domain/repositories/user_profile_repository.dart';
// Ggf. auch ChallengeRepository, um Challenge-Daten zu validieren

class AcceptChallengeUseCase {
  final UserProfileRepository userProfileRepository;
  AcceptChallengeUseCase({required this.userProfileRepository /*, required this.challengeRepository */});

  Future<bool> call(UserTaskParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;
    // Hier könnte Logik stehen: Prüfe, ob Challenge existiert (via ChallengeRepo),
    // ob User die Voraussetzungen erfüllt etc.
    return await userProfileRepository.addTaskToOngoing(params.userId, params.challengeId);
  }
}

// Eine generische Params-Klasse für User-Task-Interaktionen
class UserTaskParams {
  final String userId;
  final String challengeId;
  UserTaskParams({required this.userId, required this.challengeId});
}