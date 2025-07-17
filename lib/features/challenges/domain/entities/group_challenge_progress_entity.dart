import 'package:equatable/equatable.dart';

/// Stores the central progress of a group challenge.
class GroupChallengeProgressEntity extends Equatable {
  final String id;
  final String challengeId;
  final String contextId; // Added
  final List<String> participantIds;
  final int totalTasksRequired;
  final int completedTasksCount;
  final List<int> unlockedMilestones;
  final DateTime createdAt;

  const GroupChallengeProgressEntity({
    required this.id,
    required this.challengeId,
    required this.contextId, // Added
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
        contextId, // Added
        participantIds,
        totalTasksRequired,
        completedTasksCount,
        unlockedMilestones,
        createdAt,
      ];
}