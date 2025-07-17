import 'package:equatable/equatable.dart';

import '../../../../core/usecases/use_case.dart';
import '/features/profile/domain/repositories/user_profile_repository.dart';

/// This Use Case removes a challenge from a user's "Ongoing" list.
class RemoveChallengeFromOngoingUseCase implements UseCase<bool, UserTaskParams> {
  final UserProfileRepository userProfileRepository;

  RemoveChallengeFromOngoingUseCase(this.userProfileRepository);

  @override
  Future<bool> call(UserTaskParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;
    return await userProfileRepository.removeTaskFromOngoing(params.userId, params.challengeId);
  }
}

/// A reusable data container for Use Cases that describe an
/// interaction between a user and a task/challenge.
class UserTaskParams extends Equatable {
  final String userId;
  final String challengeId;

  const UserTaskParams({required this.userId, required this.challengeId});

  @override
  List<Object?> get props => [userId, challengeId];
}
