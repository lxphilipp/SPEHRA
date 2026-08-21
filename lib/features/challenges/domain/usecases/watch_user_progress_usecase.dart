import '../entities/challenge_progress_entity.dart';
import '../repositories/challenge_progress_repository.dart';

/// Streams every participation ([ChallengeProgressEntity]) of a user.
///
/// Consumers derive "running" and "completed" challenges from this list
/// instead of reading redundant ID lists from the user profile.
class WatchUserProgressUseCase {
  final ChallengeProgressRepository _repository;

  WatchUserProgressUseCase(this._repository);

  Stream<List<ChallengeProgressEntity>> call(String userId) {
    if (userId.isEmpty) return Stream.value(const []);
    return _repository.watchUserProgress(userId);
  }
}
