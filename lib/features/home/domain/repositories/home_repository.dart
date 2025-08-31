/// Abstract class for a repository that handles home screen related data.
///
/// This includes fetching SDG navigation items and challenge previews.
import '../entities/challenge_preview_entity.dart';
import '../entities/sdg_navigation_item_entity.dart';

/// Abstract class for a repository that handles home screen related data.
///
/// This includes fetching SDG navigation items and challenge previews.
abstract class HomeRepository {
  /// Fetches a list of SDG (Sustainable Development Goals) navigation items.
  ///
  /// These items are typically displayed on the home screen to allow users
  /// to navigate to different SDG-related sections or content.
  ///
  /// Returns a `Future` that completes with a list of [SdgNavigationItemEntity]
  /// objects, or `null` if an error occurs or no items are found.
  Future<List<SdgNavigationItemEntity>?> getSdgNavigationItems();

  /// Fetches a stream of challenge previews based on a list of challenge IDs.
  ///
  /// This method is used to get a limited list of challenge previews,
  /// for example, to display on a home screen or a summary view.
  ///
  /// Parameters:
  ///   [challengeIds]: A list of unique identifiers for the challenges
  ///                   to fetch previews for.
  ///   [limit]: The maximum number of challenge previews to return.
  ///
  /// Returns a `Stream` that emits a list of [ChallengePreviewEntity] objects
  /// matching the provided IDs, or `null` if an error occurs. The stream
  /// will update if the underlying data for these challenges changes.
  Stream<List<ChallengePreviewEntity>?> getChallengesPreviewByIds({
    required List<String> challengeIds,
    required int limit,
  });
}
