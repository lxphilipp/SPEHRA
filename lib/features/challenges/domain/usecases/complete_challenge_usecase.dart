import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../entities/challenge_entity.dart';
import '../repositories/challenge_progress_repository.dart';
import '../repositories/challenge_repository.dart';

/// Encapsulates the complex logic for completing a challenge.
/// Awards base points to the player and distributes team bonuses when milestones are reached.
class CompleteChallengeUseCase implements UseCase<bool, CompleteChallengeParams> {
  final UserProfileRepository _userProfileRepository;
  final ChallengeRepository _challengeRepository;
  final ChallengeProgressRepository _progressRepository;

  // --- Milestone and bonus configuration ---
  static const Map<int, double> _milestones = {
    50: 0.10,  // At 50% progress, there's a 10% bonus
    100: 0.25, // At 100% progress, there's a 25% bonus
  };

  CompleteChallengeUseCase({
    required UserProfileRepository userProfileRepository,
    required ChallengeRepository challengeRepository,
    required ChallengeProgressRepository progressRepository,
  })  : _userProfileRepository = userProfileRepository,
        _challengeRepository = challengeRepository,
        _progressRepository = progressRepository;

  @override
  Future<bool> call(CompleteChallengeParams params) async {
    try {
      // 1. Fetch challenge data and base points
      final challenge = await _challengeRepository.getChallengeById(params.challengeId);
      if (challenge == null) {
        AppLogger.warning("CompleteChallengeUseCase: Challenge ${params.challengeId} not found.");
        return false;
      }
      final int basePoints = challenge.calculatedPoints;

      // 2. Update player's individual progress (award base points)
      await _userProfileRepository.markTaskAsCompleted(
        userId: params.userId,
        challengeId: params.challengeId,
        pointsEarned: basePoints,
      );
      AppLogger.info("Base points ($basePoints) awarded to user ${params.userId}.");

      // 3. Check if this is part of a group challenge
      final progressId = '${params.userId}_${params.challengeId}';
      final individualProgress = await _progressRepository.watchChallengeProgress(progressId).first;
      final inviteId = individualProgress?.inviteId;

      if (inviteId == null) {
        AppLogger.info("Solo challenge completed. No bonus awarded.");
        return true; // Was a solo challenge -> successfully completed.
      }

      // 4. Fetch group progress
      final groupProgress = await _progressRepository.getGroupProgress(inviteId);
      if (groupProgress == null) {
        AppLogger.warning("Group progress for Invite $inviteId not found. No bonus awarded.");
        return true;
      }

      // 5. Check if new milestones were reached with this completion
      final progressPercentage = (groupProgress.completedTasksCount * 100) / groupProgress.totalTasksRequired;

      for (var milestoneEntry in _milestones.entries) {
        final int milestone = milestoneEntry.key;
        final double bonusFactor = milestoneEntry.value;

        // Check if milestone is reached but not yet awarded
        if (progressPercentage >= milestone && !groupProgress.unlockedMilestones.contains(milestone)) {

          final bonusPoints = (basePoints * bonusFactor).round();
          AppLogger.info("Milestone ($milestone%) reached! Distributing $bonusPoints bonus points to all participants.");

          // Distribute bonus to ALL participants in the group
          await _userProfileRepository.addBonusPoints(
            userIds: groupProgress.participantIds,
            points: bonusPoints,
          );

          // Mark milestone as "awarded" to prevent double awarding
          await _progressRepository.markMilestoneAsAwarded(inviteId, milestone);
        }
      }

      return true;

    } catch (e, s) {
      AppLogger.error("Error in CompleteChallengeUseCase", e, s);
      return false;
    }
  }
}

/// Data container for the parameters of the CompleteChallengeUseCase.
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