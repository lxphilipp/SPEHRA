import '../entities/challenge_entity.dart';

abstract class ChallengeRepository {
  Stream<List<ChallengeEntity>?> getAllChallengesStream();
  Future<ChallengeEntity?> getChallengeById(String challengeId);
  Future<String?> createChallenge({ // Gibt die ID der neuen Challenge oder null zurück
    required String title,
    required String description,
    required String task,
    required int points,
    required List<String> categories,
    required String difficulty,
    // required String createdByUserId, // Falls benötigt
  });
}