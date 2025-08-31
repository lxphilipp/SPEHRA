import '../entities/address_entity.dart';
import '../entities/challenge_entity.dart';
import '../entities/trackable_task.dart';

/// Abstract class for managing challenges.
abstract class ChallengeRepository {
  /// Returns a stream of all challenges.
  Stream<List<ChallengeEntity>?> getAllChallengesStream();

  /// Returns a challenge by its ID.
  ///
  /// Takes a [challengeId] and returns a [Future] of [ChallengeEntity] or null.
  Future<ChallengeEntity?> getChallengeById(String challengeId);

  /// Creates a new challenge.
  ///
  /// Takes [title], [description], [categories], [authorId], [tasks], and an optional [llmFeedback].
  /// Returns a [Future] of the created challenge's ID or null.
  Future<String?> createChallenge({
    required String title,
    required String description,
    required List<String> categories,
    required String authorId,
    required List<TrackableTask> tasks,
    Map<String, String>? llmFeedback,
  });

  /// Gets LLM feedback for a challenge.
  ///
  /// Takes a [step] and [challengeData].
  /// Returns a [Future] of the LLM feedback or null.
  Future<String?> getLlmFeedback({
    required String step,
    required ChallengeEntity challengeData,
  });

  /// Searches for a location based on a query.
  ///
  /// Takes a [query] string and returns a [Future] of a list of [AddressEntity].
  Future<List<AddressEntity>> searchLocation(String query);
}