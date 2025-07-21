import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../chat/domain/entities/message_entity.dart';
import '../../../chat/domain/usecases/get_chat_user_by_id_usecase.dart';
import '../../../chat/domain/usecases/send_message_usecase.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../entities/task_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';
import '../repositories/challenge_repository.dart';
import 'get_game_balance_usecase.dart';

/// Handles updating the progress of a single task.
/// If the task is part of a group challenge, this use case is also responsible for:
/// 1. Incrementing the total group progress.
/// 2. Checking if any team milestones have been reached.
/// 3. Distributing team bonuses IMMEDIATELY and RETROACTIVELY to all members if a milestone is unlocked.
/// 4. Sending appropriate system messages to the group chat.
class UpdateTaskProgressUseCase implements UseCase<void, UpdateTaskProgressParams> {
  final ChallengeProgressRepository _progressRepository;
  final UserProfileRepository _userProfileRepository;
  final ChallengeRepository _challengeRepository;
  final SendMessageUseCase _sendMessageUseCase;
  final GetChatUserByIdUseCase _getChatUserByIdUseCase;
  final GetGameBalanceUseCase _getGameBalanceUseCase;

  UpdateTaskProgressUseCase({
    required ChallengeProgressRepository progressRepository,
    required UserProfileRepository userProfileRepository,
    required ChallengeRepository challengeRepository,
    required SendMessageUseCase sendMessageUseCase,
    required GetChatUserByIdUseCase getChatUserByIdUseCase,
    required GetGameBalanceUseCase getGameBalanceUseCase,
  })  : _progressRepository = progressRepository,
        _userProfileRepository = userProfileRepository,
        _challengeRepository = challengeRepository,
        _sendMessageUseCase = sendMessageUseCase,
        _getChatUserByIdUseCase = getChatUserByIdUseCase,
        _getGameBalanceUseCase = getGameBalanceUseCase;

  @override
  Future<void> call(UpdateTaskProgressParams params) async {
    // Step 1: Update the individual task state
    final newState = TaskProgressEntity(
      isCompleted: params.isCompleted,
      progressValue: params.newValue,
      completedAt: params.isCompleted ? DateTime.now() : null,
    );
    await _progressRepository.updateTaskState(params.progressId, params.taskIndex.toString(), newState);

    // Only proceed with group logic if the task was marked as completed
    if (!params.isCompleted) return;

    final individualProgress = await _progressRepository.watchChallengeProgress(params.progressId).first;
    if (individualProgress?.inviteId == null) return; // Not a group challenge, we are done.

    // Step 2: Atomically increment group progress and get the new, updated state
    final updatedGroupProgress = await _progressRepository.incrementGroupProgress(individualProgress!.inviteId!);
    if (updatedGroupProgress == null) return;

    // --- MILESTONE & BONUS DISTRIBUTION LOGIC ---
    final balance = await _getGameBalanceUseCase(NoParams());
    final challenge = await _challengeRepository.getChallengeById(updatedGroupProgress.challengeId);
    if (challenge == null) return;

    final int basePoints = challenge.calculatePoints(balance);
    final progressPercentage = (updatedGroupProgress.completedTasksCount * 100) / updatedGroupProgress.totalTasksRequired;

    // Check for newly reached milestones that have not been awarded yet
    for (var milestoneEntry in balance.groupChallengeMilestones.entries) {
      final int milestone = milestoneEntry.key;
      final double bonusFactor = milestoneEntry.value;

      if (progressPercentage >= milestone && !updatedGroupProgress.unlockedMilestones.contains(milestone)) {
        final bonusPoints = (basePoints * bonusFactor).round();
        AppLogger.info("Milestone ($milestone%) reached! Distributing $bonusPoints bonus points to all participants.");

        // ACTION 1: Immediately distribute bonus points to ALL participants
        await _userProfileRepository.addBonusPoints(userIds: updatedGroupProgress.participantIds, points: bonusPoints);

        // ACTION 2: Send the celebratory milestone message to the chat
        final milestoneMessage = MessageEntity(
            id: '', fromId: 'system', toId: updatedGroupProgress.contextId,
            msg: "🎉 Milestone Unlocked: $milestone%! The whole team gets a bonus of $bonusPoints points!",
            type: MessageType.milestoneUnlocked, createdAt: DateTime.now()
        );
        await _sendMessageUseCase(message: milestoneMessage, contextId: updatedGroupProgress.contextId, isGroupMessage: true);

        // ACTION 3: Mark the milestone as awarded to prevent double distribution
        await _progressRepository.markMilestoneAsAwarded(updatedGroupProgress.id, milestone);
      }
    }
    // --- End of Milestone Logic ---

    // Finally, send the regular, informational progress update message
    final user = await _getChatUserByIdUseCase(userId: individualProgress.userId);
    if (user != null) {
      final messageText = "🏆 ${user.name} completed a task! Progress: [${updatedGroupProgress.completedTasksCount}/${updatedGroupProgress.totalTasksRequired}]";
      final systemMessage = MessageEntity(
          id: '', fromId: 'system', toId: updatedGroupProgress.contextId,
          msg: messageText, type: MessageType.progressUpdate, createdAt: DateTime.now()
      );
      await _sendMessageUseCase(message: systemMessage, contextId: updatedGroupProgress.contextId, isGroupMessage: true);
    }
  }
}

/// Parameters needed to update the progress of a specific task.
class UpdateTaskProgressParams extends Equatable {
  final String progressId;
  final int taskIndex;
  final dynamic newValue;
  final bool isCompleted;

  const UpdateTaskProgressParams({
    required this.progressId,
    required this.taskIndex,
    this.newValue,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [progressId, taskIndex, newValue, isCompleted];
}