import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sdg/features/challenges/data/models/task_progress_modell.dart';

import '../../domain/entities/challenge_progress_entity.dart';

// Das Haupt-Model für den gesamten Challenge-Fortschritt
class ChallengeProgressModel {
  final String id;
  final String userId;
  final String challengeId;
  final Timestamp startedAt;
  final Timestamp? endsAt;
  final Map<String, TaskProgressModel> taskStates;

  ChallengeProgressModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    this.endsAt,
    required this.taskStates,
  });

  // KORRIGIERTE METHODE
  factory ChallengeProgressModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    // Sichere Umwandlung der taskStates-Map
    final taskStatesData = data['taskStates'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, TaskProgressModel> mappedTaskStates = taskStatesData.map(
          (key, value) => MapEntry(
        key.toString(), // Stellt sicher, dass der Schlüssel immer ein String ist
        TaskProgressModel.fromMap(value as Map<String, dynamic>),
      ),
    );

    return ChallengeProgressModel(
      id: snap.id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      startedAt: data['startedAt'] ?? Timestamp.now(),
      endsAt: data['endsAt'] as Timestamp?,
      taskStates: mappedTaskStates, // Verwendet die sicher umgewandelte Map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'startedAt': startedAt,
      'endsAt': endsAt,
      'taskStates': taskStates.map((key, value) => MapEntry(key, value.toMap())),
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
        ));
  }
}