import 'package:equatable/equatable.dart';
import 'task_progress_entity.dart';

class ChallengeProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String challengeId;
  final DateTime startedAt;
  final DateTime? endsAt;
  final Map<String, TaskProgressEntity> taskStates;
  final String? inviteId;

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