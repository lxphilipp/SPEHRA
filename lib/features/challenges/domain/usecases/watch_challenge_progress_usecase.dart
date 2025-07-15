import '../entities/challenge_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

class WatchChallengeProgressUseCase {
  final ChallengeProgressRepository _repository;

  WatchChallengeProgressUseCase(this._repository);

  Stream<ChallengeProgressEntity?> call(String progressId) {
    return _repository.watchChallengeProgress(progressId);
  }
}