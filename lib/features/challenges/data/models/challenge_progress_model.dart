import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sdg/features/challenges/data/models/task_progress_modell.dart';
import '../../domain/entities/challenge_progress_entity.dart';

class ChallengeProgressModel {
  final String id;
  final String userId;
  final String challengeId;
  final Timestamp startedAt;
  final Timestamp? endsAt;
  final Map<String, TaskProgressModel> taskStates;
  final String? inviteId;

  ChallengeProgressModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    this.endsAt,
    required this.taskStates,
    this.inviteId,
  });

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