import 'package:equatable/equatable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../entities/challenge_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

/// Removes a user's participation in a running challenge.
///
/// The participation record is the single source of truth for "ongoing"
/// challenges, so deleting it is all that is needed to drop the challenge
/// from the user's running list.
class AbandonChallengeUseCase implements UseCase<bool, UserTaskParams> {
  final ChallengeProgressRepository _progressRepository;

  AbandonChallengeUseCase(this._progressRepository);

  @override
  Future<bool> call(UserTaskParams params) async {
    if (params.userId.isEmpty || params.challengeId.isEmpty) return false;
    try {
      await _progressRepository.deleteChallengeProgress(
        ChallengeProgressEntity.buildId(params.userId, params.challengeId),
      );
      return true;
    } catch (e, s) {
      AppLogger.error('AbandonChallengeUseCase failed', e, s);
      return false;
    }
  }
}

/// A reusable data container for use cases that describe an
/// interaction between a user and a challenge.
class UserTaskParams extends Equatable {
  final String userId;
  final String challengeId;

  const UserTaskParams({required this.userId, required this.challengeId});

  @override
  List<Object?> get props => [userId, challengeId];
}
