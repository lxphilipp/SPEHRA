import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../repositories/challenge_progress_repository.dart';
import '../repositories/challenge_repository.dart';
import 'get_game_balance_usecase.dart';

/// {@template complete_challenge_usecase}
/// Use case for completing a challenge.
///
/// This use case handles the logic for marking a challenge as completed,
/// awarding points to the user, and distributing bonus points if applicable
/// for group challenges.
/// {@endtemplate}
class CompleteChallengeUseCase implements UseCase<bool, CompleteChallengeParams> {
  /// The user profile repository.
  final UserProfileRepository _userProfileRepository;
  /// The challenge repository.
  final ChallengeRepository _challengeRepository;
  /// The challenge progress repository.
  final ChallengeProgressRepository _progressRepository;
  /// The use case for getting the game balance.
  final GetGameBalanceUseCase _getGameBalanceUseCase;

  /// {@macro complete_challenge_usecase}
  CompleteChallengeUseCase({
    required UserProfileRepository userProfileRepository,
    required ChallengeRepository challengeRepository,
    required ChallengeProgressRepository progressRepository,
    required GetGameBalanceUseCase getGameBalanceUseCase,
  })  : _userProfileRepository = userProfileRepository,
        _challengeRepository = challengeRepository,
        _progressRepository = progressRepository,
        _getGameBalanceUseCase = getGameBalanceUseCase;

  /// Executes the use case to complete a challenge.
  ///
  /// Takes [CompleteChallengeParams] as input, which contains the user ID
  /// and challenge ID.
  ///
  /// Returns `true` if the challenge was completed successfully, `false` otherwise.
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

/// {@template complete_challenge_params}
/// Parameters for the [CompleteChallengeUseCase].
/// {@endtemplate}
class CompleteChallengeParams extends Equatable {
  /// The ID of the user completing the challenge.
  final String userId;
  /// The ID of the challenge being completed.
  final String challengeId;

  /// {@macro complete_challenge_params}
  const CompleteChallengeParams({
    required this.userId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [userId, challengeId];
}