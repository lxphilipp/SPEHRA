import '../entities/challenge_preview_entity.dart';
import '../entities/sdg_navigation_item_entity.dart';

abstract class HomeRepository {
  Future<List<SdgNavigationItemEntity>?> getSdgNavigationItems();

  Stream<List<ChallengePreviewEntity>?> getChallengesPreviewByIds({
    required List<String> challengeIds,
    required int limit,
  });
}