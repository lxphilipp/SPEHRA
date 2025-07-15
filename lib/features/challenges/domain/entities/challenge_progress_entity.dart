import 'package:equatable/equatable.dart';
import 'task_progress_entity.dart';

class ChallengeProgressEntity extends Equatable {
  final String id; // Eindeutige ID, z.B. "userId_challengeId"
  final String userId;
  final String challengeId;
  final DateTime startedAt;
  final DateTime? endsAt; // Optional für zeitlich begrenzte Challenges
  final Map<String, TaskProgressEntity> taskStates; // Key: Task Index als String


  const ChallengeProgressEntity({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    this.endsAt,
    required this.taskStates,
  });

  @override
  List<Object?> get props => [id, userId, challengeId, startedAt, endsAt, taskStates];
}