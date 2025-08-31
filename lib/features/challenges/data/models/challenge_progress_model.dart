import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sdg/features/challenges/data/models/task_progress_modell.dart';
import '../../domain/entities/challenge_progress_entity.dart';

/// Represents the data model for challenge progress.
///
/// This class is used to map challenge progress data between Firestore
/// and the domain layer [ChallengeProgressEntity].
class ChallengeProgressModel {
  /// The unique identifier of the challenge progress.
  final String id;

  /// The unique identifier of the user.
  final String userId;

  /// The unique identifier of the challenge.
  final String challengeId;

  /// The timestamp when the challenge was started.
  final Timestamp startedAt;

  /// The timestamp when the challenge ends. Can be null if there's no end date.
  final Timestamp? endsAt;

  /// A map representing the progress of each task within the challenge.
  ///
  /// The key is the task ID and the value is a [TaskProgressModel].
  final Map<String, TaskProgressModel> taskStates;

  /// The unique identifier of the invite used to join the challenge, if applicable.
  final String? inviteId;

  /// Creates a [ChallengeProgressModel].
  ChallengeProgressModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    this.endsAt,
    required this.taskStates,
    this.inviteId,
  });

  /// Creates a [ChallengeProgressModel] from a Firestore [DocumentSnapshot].
  factory ChallengeProgressModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    final taskStatesData = data['taskStates'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, TaskProgressModel> mappedTaskStates = taskStatesData.map(
          (key, value) => MapEntry(
        key.toString(),
        TaskProgressModel.fromMap(value as Map<String, dynamic>),
      ),
    );

    return ChallengeProgressModel(
      id: snap.id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      startedAt: data['startedAt'] ?? Timestamp.now(),
      endsAt: data['endsAt'] as Timestamp?,
      taskStates: mappedTaskStates,
      inviteId: data['inviteId'] as String?, // <-- NEU
    );
  }

  /// Converts this [ChallengeProgressModel] to a [Map] for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'startedAt': startedAt,
      'endsAt': endsAt,
      'taskStates': taskStates.map((key, value) => MapEntry(key, value.toMap())),
      if (inviteId != null) 'inviteId': inviteId, // Only save if present
    };
  }

  /// Creates a [ChallengeProgressModel] from a [ChallengeProgressEntity].
  factory ChallengeProgressModel.fromEntity(ChallengeProgressEntity entity) {
    return ChallengeProgressModel(
      id: entity.id,
      userId: entity.userId,
      challengeId: entity.challengeId,
      startedAt: Timestamp.fromDate(entity.startedAt),
      endsAt: entity.endsAt != null ? Timestamp.fromDate(entity.endsAt!) : null,
      taskStates: entity.taskStates.map(
            (key, value) => MapEntry(key.toString(), TaskProgressModel.fromEntity(value)),
      ),
      inviteId: entity.inviteId,
    );
  }

  /// Converts this [ChallengeProgressModel] to a [ChallengeProgressEntity].
  ChallengeProgressEntity toEntity() {
    return ChallengeProgressEntity(
      id: id,
      userId: userId,
      challengeId: challengeId,
      startedAt: startedAt.toDate(),
      endsAt: endsAt?.toDate(),
      taskStates: taskStates.map(
            (key, value) => MapEntry(key.toString(), value.toEntity()),
      ),
      inviteId: inviteId,
    );
  }
}
