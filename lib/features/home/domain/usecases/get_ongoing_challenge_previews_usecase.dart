import 'dart:async';
import '/core/utils/app_logger.dart';
import '/features/profile/domain/entities/user_profile_entity.dart';
import '/features/challenges/domain/entities/challenge_entity.dart';
import '/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';

class GetOngoingChallengePreviewsUseCase {
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;

  GetOngoingChallengePreviewsUseCase(this._getChallengeByIdUseCase);

  Future<List<ChallengeEntity>?> call({
    required UserProfileEntity userProfile,
    required int limit,
  }) async {
    if (limit <= 0) {
      return [];
    }

    final List<ChallengeEntity> previews = [];
    List<Future<ChallengeEntity?>> futures = [];

    for (String taskId in userProfile.ongoingTasks.take(limit)) {
      futures.add(_getChallengeByIdUseCase(taskId));
    }

    try {
      final results = await Future.wait(futures);
      for (var challenge in results) {
        if (challenge != null) {
          previews.add(challenge);
        }
      }
      return previews;
    } catch (e) {
      AppLogger.error("GetOngoingChallengePreviewsUseCase: Error loading ongoing challenge previews", e);
      return null;
    }
  }
}