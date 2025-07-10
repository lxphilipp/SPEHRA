import 'package:equatable/equatable.dart';

import '../../../../core/usecases/use_case.dart';
import '/features/profile/domain/repositories/user_profile_repository.dart';

/// Dieser Use Case entfernt eine Challenge aus der "Ongoing"-Liste eines Nutzers.
class RemoveChallengeFromOngoingUseCase implements UseCase<bool, UserTaskParams> {
  final UserProfileRepository userProfileRepository;

  RemoveChallengeFromOngoingUseCase(this.userProfileRepository);

  @override
  Future<bool> call(UserTaskParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;
    return await userProfileRepository.removeTaskFromOngoing(params.userId, params.challengeId);
  }
}

/// Ein wiederverwendbarer Daten-Container für Use Cases, die eine
/// Interaktion zwischen einem Nutzer und einer Aufgabe/Challenge beschreiben.
class UserTaskParams extends Equatable {
  final String userId;
  final String challengeId;

  const UserTaskParams({required this.userId, required this.challengeId});

  @override
  List<Object?> get props => [userId, challengeId];
}
