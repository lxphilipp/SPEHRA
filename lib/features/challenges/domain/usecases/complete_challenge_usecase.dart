import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../repositories/challenge_progress_repository.dart';
import '../repositories/challenge_repository.dart';
import 'get_game_balance_usecase.dart';

class CompleteChallengeUseCase implements UseCase<bool, CompleteChallengeParams> {
  final UserProfileRepository _userProfileRepository;
  final ChallengeRepository _challengeRepository;
  final ChallengeProgressRepository _progressRepository;
  final GetGameBalanceUseCase _getGameBalanceUseCase;

  CompleteChallengeUseCase({
    required UserProfileRepository userProfileRepository,
    required ChallengeRepository challengeRepository,
    required ChallengeProgressRepository progressRepository,
    required GetGameBalanceUseCase getGameBalanceUseCase,
  })  : _userProfileRepository = userProfileRepository,
        _challengeRepository = challengeRepository,
        _progressRepository = progressRepository,
        _getGameBalanceUseCase = getGameBalanceUseCase;

  @override
  Future<bool> call(CompleteChallengeParams params) async {
    try {
      final balance = await _getGameBalanceUseCase(NoParams());

      final challenge = await _challengeRepository.getChallengeById(params.challengeId);
      if (challenge == null) {
        AppLogger.warning("CompleteChallengeUseCase: Challenge ${params.challengeId} not found.");
        return false;
      }

      final int basePoints = challenge.calculatePoints(balance);

      await _userProfileRepository.markTaskAsCompleted(
        userId: params.userId,
        challengeId: params.challengeId,
        pointsEarned: basePoints,
      );
      AppLogger.info("Base points ($basePoints) awarded to user ${params.userId}.");

      final progressId = '${params.userId}_${params.challengeId}';
      final individualProgress = await _progressRepository.watchChallengeProgress(progressId).first;
      final inviteId = individualProgress?.inviteId;

      if (inviteId == null) {
        AppLogger.info("Solo challenge completed. No bonus logic triggered.");
        return true;
      }

      final groupProgress = await _progressRepository.getGroupProgress(inviteId);
      if (groupProgress == null) {
        AppLogger.warning("Group progress for Invite $inviteId not found. Cannot award bonus.");
        return true;
      }

      final progressPercentage = (groupProgress.completedTasksCount * 100) / groupProgress.totalTasksRequired;

      for (var milestoneEntry in balance.groupChallengeMilestones.entries) {
        final int milestone = milestoneEntry.key;
        final double bonusFactor = milestoneEntry.value;

        if (progressPercentage >= milestone && !groupProgress.unlockedMilestones.contains(milestone)) {
          final bonusPoints = (basePoints * bonusFactor).round();
          AppLogger.info("Milestone ($milestone%) reached! Distributing $bonusPoints bonus points to all participants.");

          // Distribute bonus to ALL participants in the group
          await _userProfileRepository.addBonusPoints(
            userIds: groupProgress.participantIds,
            points: bonusPoints,
          );

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