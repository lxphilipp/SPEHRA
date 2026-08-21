import 'package:equatable/equatable.dart';
import 'task_progress_entity.dart';

/// Represents a user's participation in a specific challenge and the
/// progress made within it.
///
/// This is the associative entity between a user and a challenge. A user's
/// running and completed challenges are *derived* from these records:
/// a participation without [completedAt] is running, one with [completedAt]
/// is completed. Nothing else stores those lists.
class ChallengeProgressEntity extends Equatable {
  /// The unique identifier of the challenge progress
  /// (by convention `'<userId>_<challengeId>'`).
  final String id;

  /// The unique identifier of the user.
  final String userId;

  /// The unique identifier of the challenge.
  final String challengeId;

  /// The date and time when the challenge was started.
  final DateTime startedAt;

  /// The deadline by which the challenge should be finished.
  /// Can be null if the challenge has no time limit.
  final DateTime? endsAt;

  /// The date and time when the user finalised the challenge and was
  /// awarded its points. Null while the challenge is still running.
  final DateTime? completedAt;

  /// A map representing the progress of each task in the challenge.
  /// The key is the task index as a string, and the value is the [TaskProgressEntity].
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
    this.completedAt,
    required this.taskStates,
    this.inviteId,
  });

  /// Builds the conventional progress document ID for a user/challenge pair.
  static String buildId(String userId, String challengeId) => '${userId}_$challengeId';

  /// Whether the user has finalised this challenge.
  bool get isCompleted => completedAt != null;

  /// Whether this challenge is still running for the user.
  bool get isOngoing => completedAt == null;

  /// Whether every task in this challenge has been marked complete
  /// (the precondition for finalising it).
  bool get allTasksDone =>
      taskStates.isNotEmpty && taskStates.values.every((task) => task.isCompleted);

  @override
  List<Object?> get props =>
      [id, userId, challengeId, startedAt, endsAt, completedAt, taskStates, inviteId];
}
