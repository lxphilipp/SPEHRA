import '../entities/challenge_preview_entity.dart';
import '../entities/sdg_navigation_item_entity.dart';

abstract class HomeRepository {
  Future<List<SdgNavigationItemEntity>?> getSdgNavigationItems();

  // Nimmt jetzt die Task-IDs direkt als Parameter!
  Stream<List<ChallengePreviewEntity>?> getChallengesPreviewByIds({
    required List<String> challengeIds, // Die spezifischen IDs (ongoing oder completed)
    required int limit,
  });
}