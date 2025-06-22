// lib/features/challenges/domain/usecases/complete_challenge_usecase.dart
import '/core/utils/app_logger.dart';
import '/features/profile/domain/repositories/user_profile_repository.dart';
import '../repositories/challenge_repository.dart'; // Eigenes Repository
// Eigene Entity

class CompleteChallengeUseCase {
  final UserProfileRepository userProfileRepository;
  final ChallengeRepository challengeRepository;

  CompleteChallengeUseCase({
    required this.userProfileRepository,
    required this.challengeRepository,
  });

  Future<bool> call(CompleteChallengeParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;

    // 1. Punkte der Challenge holen
    final challengeEntity = await challengeRepository.getChallengeById(params.challengeId);
    if (challengeEntity == null) {
      AppLogger.warning("CompleteChallengeUseCase: Challenge ${params.challengeId} not found");
      return false; // Challenge nicht gefunden
    }
    final int pointsEarned = challengeEntity.points;

    // 2. User-Profil aktualisieren
    return await userProfileRepository.markTaskAsCompleted(
      userId: params.userId,
      challengeId: params.challengeId,
      pointsEarned: pointsEarned, // Die geholten Punkte übergeben
    );
  }
}

class CompleteChallengeParams {
  final String userId;
  final String challengeId;
  // pointsEarned wird jetzt vom UseCase selbst ermittelt
  // final int pointsEarned;

  CompleteChallengeParams({
    required this.userId,
    required this.challengeId,
    // required this.pointsEarned,
  });
}