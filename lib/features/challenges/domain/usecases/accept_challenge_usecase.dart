import 'package:flutter_sdg/features/challenges/domain/usecases/remove_challenge_from_ongoing_usecase.dart';

import '/features/profile/domain/repositories/user_profile_repository.dart';

class AcceptChallengeUseCase {
  final UserProfileRepository userProfileRepository;
  AcceptChallengeUseCase({required this.userProfileRepository});

  Future<bool> call(UserTaskParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;
    return await userProfileRepository.addTaskToOngoing(params.userId, params.challengeId);
  }
}