import 'package:equatable/equatable.dart';
import 'task_progress_entity.dart';

/// Represents the progress of a user in a specific challenge.
class ChallengeProgressEntity extends Equatable {
  /// The unique identifier of the challenge progress.
  final String id;

  /// The unique identifier of the user.
  final String userId;

  /// The unique identifier of the challenge.
  final String challengeId;

  /// The date and time when the challenge was started.
  final DateTime startedAt;

  /// The date and time when the challenge ends. Can be null if the challenge has no end date.
  final DateTime? endsAt;

  /// A map representing the progress of each task in the challenge.
  /// The key is the task ID, and the value is the [TaskProgressEntity].
  final Map<String, TaskProgressEntity> taskStates;

  /// The unique identifier of the invite used to join the challenge, if applicable.
  final String? inviteId;

  /// Creates a [ChallengeProgressEntity].
  const ChallengeProgressEntity({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    this.endsAt,
    required this.taskStates,
    this.inviteId,
  });

  @override
  List<Object?> get props => [id, userId, challengeId, startedAt, endsAt, taskStates, inviteId];
}
