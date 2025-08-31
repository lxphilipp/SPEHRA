import 'package:equatable/equatable.dart';

/// Stores the central progress of a group challenge.
class GroupChallengeProgressEntity extends Equatable {
  /// The unique identifier of the group challenge progress.
  final String id;

  /// The identifier of the challenge this progress belongs to.
  final String challengeId;

  /// The identifier of the context (e.g., group) this progress belongs to.
  final String contextId;

  /// A list of participant identifiers involved in this group challenge.
  final List<String> participantIds;

  /// The total number of tasks required to complete the challenge.
  final int totalTasksRequired;

  /// The number of tasks that have been completed.
  final int completedTasksCount;

  /// A list of milestone indices that have been unlocked.
  final List<int> unlockedMilestones;

  /// The timestamp when the group challenge progress was created.
  final DateTime createdAt;

  /// Creates an instance of [GroupChallengeProgressEntity].
  const GroupChallengeProgressEntity({
    required this.id,
    required this.challengeId,
    required this.contextId,
    required this.participantIds,
    required this.totalTasksRequired,
    required this.completedTasksCount,
    required this.unlockedMilestones,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        challengeId,
        contextId,
        participantIds,
        totalTasksRequired,
        completedTasksCount,
        unlockedMilestones,
        createdAt,
      ];
}
