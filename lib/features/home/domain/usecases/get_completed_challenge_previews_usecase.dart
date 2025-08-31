import 'dart:async';
import '/core/utils/app_logger.dart';
import '/features/profile/domain/entities/user_profile_entity.dart';
import '/features/challenges/domain/entities/challenge_entity.dart';
import '/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';

/// A use case responsible for fetching a list of completed challenge previews.
///
/// This use case takes a [UserProfileEntity] and a [limit] as input and
/// retrieves the challenge details for the completed tasks, up to the specified limit.
class GetCompletedChallengePreviewsUseCase {
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;

  /// Creates an instance of [GetCompletedChallengePreviewsUseCase].
  ///
  /// Requires a [GetChallengeByIdUseCase] to fetch individual challenge details.
  GetCompletedChallengePreviewsUseCase(this._getChallengeByIdUseCase);

  /// Executes the use case to get a list of completed challenge previews.
  ///
  /// Takes a [UserProfileEntity] containing the user's completed tasks and
  /// an integer [limit] specifying the maximum number of previews to fetch.
  ///
  /// Returns a `Future<List<ChallengeEntity>?>`. The list will contain
  /// [ChallengeEntity] objects for the completed challenges. Returns an empty list
  /// if the limit is zero or less. Returns `null` if an error occurs during
  /// the fetching process.
  Future<List<ChallengeEntity>?> call({
    required UserProfileEntity userProfile,
    required int limit,
  }) async {
    if (limit <= 0) {
      return [];
    }

    final List<ChallengeEntity> previews = [];
    List<Future<ChallengeEntity?>> futures = [];

    // Iterate over the completed tasks up to the specified limit and
    // create a list of futures to fetch each challenge.
    for (String taskId in userProfile.completedTasks.take(limit)) {
      futures.add(_getChallengeByIdUseCase(taskId));
    }

    try {
      // Wait for all challenge fetching futures to complete.
      final results = await Future.wait(futures);
      for (var challenge in results) {
        if (challenge != null) {
          previews.add(challenge);
        }
      }
      return previews;
    } catch (e) {
      AppLogger.error(
          "GetCompletedChallengePreviewsUseCase: Error loading completed challenge previews",
          e);
      return null;
    }
  }
}