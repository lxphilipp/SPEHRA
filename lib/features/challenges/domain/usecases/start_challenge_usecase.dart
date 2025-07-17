import 'package:equatable/equatable.dart';
import '../entities/challenge_entity.dart';
import '../entities/challenge_progress_entity.dart';
import '../entities/task_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

class StartChallengeUseCase {
  final ChallengeProgressRepository _progressRepository;

  StartChallengeUseCase(this._progressRepository);

  Future<void> call(StartChallengeParams params) async {
    final initialTaskStates = {
      for (var i = 0; i < params.challenge.tasks.length; i++)
        i.toString(): const TaskProgressEntity()
    };

    final progress = ChallengeProgressEntity(
      id: '${params.userId}_${params.challenge.id}',
      userId: params.userId,
      challengeId: params.challenge.id,
      startedAt: DateTime.now(),
      endsAt: params.challenge.durationInDays != null
          ? DateTime.now().add(Duration(days: params.challenge.durationInDays!))
          : null,
      taskStates: initialTaskStates,
      inviteId: params.inviteId,
    );

    return _progressRepository.createChallengeProgress(progress);
  }
}

class StartChallengeParams extends Equatable {
  final String userId;
  final ChallengeEntity challenge;
  final String? inviteId; // <-- HERE the parameter is defined

  const StartChallengeParams({
    required this.userId,
    required this.challenge,
    this.inviteId,
  });

  @override
  List<Object?> get props => [userId, challenge, inviteId];
}