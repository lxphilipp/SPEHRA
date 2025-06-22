import '/features/profile/domain/repositories/user_profile_repository.dart';
import 'accept_challenge_usecase.dart'; // Für UserTaskParams

class RemoveChallengeFromOngoingUseCase {
  final UserProfileRepository userProfileRepository;
  RemoveChallengeFromOngoingUseCase(this.userProfileRepository);

  Future<bool> call(UserTaskParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;
    return await userProfileRepository.removeTaskFromOngoing(params.userId, params.challengeId);
  }
}