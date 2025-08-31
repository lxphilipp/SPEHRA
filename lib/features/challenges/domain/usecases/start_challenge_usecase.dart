import 'package:equatable/equatable.dart';
import '../entities/challenge_entity.dart';
import '../entities/challenge_progress_entity.dart';
import '../entities/task_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

/// {@template start_challenge_usecase}
/// A use case for starting a new challenge.
///
/// This use case handles the creation of a [ChallengeProgressEntity]
/// when a user starts a challenge. It initializes the task states
/// and sets the start and end dates for the challenge.
/// {@endtemplate}
class StartChallengeUseCase {
  final ChallengeProgressRepository _progressRepository;

  /// {@macro start_challenge_usecase}
  StartChallengeUseCase(this._progressRepository);

  /// Executes the use case to start a challenge.
  ///
  /// Takes [StartChallengeParams] as input, which includes the user ID,
  /// the challenge details, and an optional invite ID.
  ///
  /// Creates a new [ChallengeProgressEntity] and persists it using the
  /// [_progressRepository].
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

/// {@template start_challenge_params}
/// Parameters required to start a challenge.
/// {@endtemplate}
class StartChallengeParams extends Equatable {
  /// The ID of the user starting the challenge.
  final String userId;

  /// The [ChallengeEntity] being started.
  final ChallengeEntity challenge;

  /// An optional ID for an invitation associated with this challenge.
  final String? inviteId; // <-- HERE the parameter is defined

  /// {@macro start_challenge_params}
  const StartChallengeParams({
    required this.userId,
    required this.challenge,
    this.inviteId,
  });

  @override
  List<Object?> get props => [userId, challenge, inviteId];
}