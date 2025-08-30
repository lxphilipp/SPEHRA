import '../entities/address_entity.dart';
import '../entities/challenge_entity.dart';
import '../entities/trackable_task.dart';

abstract class ChallengeRepository {
  Stream<List<ChallengeEntity>?> getAllChallengesStream();

  Future<ChallengeEntity?> getChallengeById(String challengeId);

  Future<String?> createChallenge({
    required String title,
    required String description,
    required List<String> categories,
    required String authorId,
    required List<TrackableTask> tasks,
    Map<String, String>? llmFeedback,
  });

  Future<String?> getLlmFeedback({
    required String step,
    required ChallengeEntity challengeData,
  });

  Future<List<AddressEntity>> searchLocation(String query);
}