import 'package:equatable/equatable.dart';
import '../repositories/challenge_progress_repository.dart';

class AddParticipantToGroupChallengeUseCase {
  final ChallengeProgressRepository _repository;

  AddParticipantToGroupChallengeUseCase(this._repository);

  Future<void> call(AddParticipantParams params) async {
    await _repository.addParticipantToGroupProgress(
      inviteId: params.inviteId,
      userId: params.userId,
      tasksPerUser: params.tasksPerUser,
    );
  }
}

class AddParticipantParams extends Equatable {
  final String inviteId;
  final String userId;
  final int tasksPerUser;

  const AddParticipantParams({
    required this.inviteId,
    required this.userId,
    required this.tasksPerUser,
  });

  @override
  List<Object?> get props => [inviteId, userId, tasksPerUser];
}
