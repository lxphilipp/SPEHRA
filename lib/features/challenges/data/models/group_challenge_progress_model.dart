import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_challenge_progress_entity.dart';

/// Serves as a data transfer and serialization object for group challenge progress in Firestore.
class GroupChallengeProgressModel {
  final String id;
  final String challengeId;
  final String contextId; // Added
  final List<String> participantIds;
  final int totalTasksRequired;
  final int completedTasksCount;
  final List<int> unlockedMilestones;
  final Timestamp createdAt;

  GroupChallengeProgressModel({
    required this.id,
    required this.challengeId,
    required this.contextId, // Added
    required this.participantIds,
    required this.totalTasksRequired,
    required this.completedTasksCount,
    required this.unlockedMilestones,
    required this.createdAt,
  });

  /// Converts a Firestore document into a GroupChallengeProgressModel.
  factory GroupChallengeProgressModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return GroupChallengeProgressModel(
      id: snap.id,
      challengeId: data['challengeId'] ?? '',
      contextId: data['contextId'] ?? '', // Added
      participantIds: List<String>.from(data['participantIds'] ?? []),
      totalTasksRequired: data['totalTasksRequired'] ?? 0,
      completedTasksCount: data['completedTasksCount'] ?? 0,
      unlockedMilestones: List<int>.from(data['unlockedMilestones'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Converts this model into a Map that can be stored in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'challengeId': challengeId,
      'contextId': contextId, // Added
      'participantIds': participantIds,
      'totalTasksRequired': totalTasksRequired,
      'completedTasksCount': completedTasksCount,
      'unlockedMilestones': unlockedMilestones,
      'createdAt': createdAt,
    };
  }

  /// Converts a domain entity into this data model.
  factory GroupChallengeProgressModel.fromEntity(GroupChallengeProgressEntity entity) {
    return GroupChallengeProgressModel(
      id: entity.id,
      challengeId: entity.challengeId,
      contextId: entity.contextId, // Added
      participantIds: entity.participantIds,
      totalTasksRequired: entity.totalTasksRequired,
      completedTasksCount: entity.completedTasksCount,
      unlockedMilestones: entity.unlockedMilestones,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  /// Converts this model into a domain entity.
  GroupChallengeProgressEntity toEntity() {
    return GroupChallengeProgressEntity(
      id: id,
      challengeId: challengeId,
      contextId: contextId, // Added
      participantIds: participantIds,
      totalTasksRequired: totalTasksRequired,
      completedTasksCount: completedTasksCount,
      unlockedMilestones: unlockedMilestones,
      createdAt: createdAt.toDate(),
    );
  }
}