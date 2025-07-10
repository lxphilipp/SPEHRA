import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '/core/utils/app_logger.dart';
import '/features/profile/domain/repositories/user_profile_repository.dart';
import '../repositories/challenge_repository.dart';

/// Dieser Use Case kapselt die Logik zum Abschließen einer Challenge durch einen Benutzer.
class CompleteChallengeUseCase implements UseCase<bool, CompleteChallengeParams> {
  final UserProfileRepository userProfileRepository;
  final ChallengeRepository challengeRepository;

  CompleteChallengeUseCase({
    required this.userProfileRepository,
    required this.challengeRepository,
  });

  @override
  Future<bool> call(CompleteChallengeParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) {
      return false;
    }

    // 1. Die vollständige Challenge-Entität abrufen.
    final challengeEntity = await challengeRepository.getChallengeById(params.challengeId);
    if (challengeEntity == null) {
      AppLogger.warning("CompleteChallengeUseCase: Challenge ${params.challengeId} not found");
      return false; // Challenge nicht gefunden, kann nicht abgeschlossen werden.
    }

    final int pointsEarned = challengeEntity.calculatedPoints;

    // 2. Das User-Profil mit den korrekt berechneten Punkten aktualisieren.
    return await userProfileRepository.markTaskAsCompleted(
      userId: params.userId,
      challengeId: params.challengeId,
      pointsEarned: pointsEarned,
    );
  }
}

/// Daten-Container für die Parameter des CompleteChallengeUseCase.
class CompleteChallengeParams extends Equatable {
  final String userId;
  final String challengeId;

  const CompleteChallengeParams({
    required this.userId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [userId, challengeId];
}