import 'dart:async';
import '/core/utils/app_logger.dart';
import '/features/challenges/domain/entities/challenge_progress_entity.dart';
import '/features/challenges/domain/entities/challenge_entity.dart';
import '/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';

class GetOngoingChallengePreviewsUseCase {
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;

  GetOngoingChallengePreviewsUseCase(this._getChallengeByIdUseCase);

  Future<List<ChallengeEntity>?> call({
    required List<ChallengeProgressEntity> userProgress,
    required int limit,
  }) async {
    if (limit <= 0) {
      return [];
    }

    final List<ChallengeEntity> previews = [];
    List<Future<ChallengeEntity?>> futures = [];

    // Running challenges are derived from the participations: newest first.
    final relevant = userProgress.where((p) => p.isOngoing).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    for (final progress in relevant.take(limit)) {
      futures.add(_getChallengeByIdUseCase(progress.challengeId));
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