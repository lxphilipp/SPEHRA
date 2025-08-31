import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/challenge_preview_entity.dart';
import '../../domain/entities/sdg_navigation_item_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/sdg_navigation_item_model.dart';

/// Implements the [HomeRepository] interface, providing concrete data handling
/// by coordinating between remote and local data sources.
class HomeRepositoryImpl implements HomeRepository {
  /// The remote data source for fetching home-related data.
  final HomeRemoteDataSource remoteDataSource;
  /// The local data source for fetching and caching home-related data.
  final HomeLocalDataSource localDataSource;

  /// Creates an instance of [HomeRepositoryImpl].
  ///
  /// Requires [remoteDataSource] for network operations and
  /// [localDataSource] for local data storage.
  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Maps a Firestore [DocumentSnapshot] to a [ChallengePreviewEntity].
  ///
  /// This private helper method converts raw Firestore document data into a
  /// structured [ChallengePreviewEntity] object.
  ChallengePreviewEntity _mapDocumentToChallengePreview(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengePreviewEntity(
      id: doc.id,
      title: data['title'] ?? 'N/A',
      difficulty: data['difficulty'] ?? 'N/A',
      points: data['points'] ?? 0,
      categories: List<String>.from(data['category'] ?? []),
    );
  }

  /// Maps an [SdgNavigationItemModel] to an [SdgNavigationItemEntity].
  ///
  /// This private helper method transforms a data model object into a domain
  /// entity object, suitable for use in the application's business logic.
  SdgNavigationItemEntity _mapSdgModelToEntity(SdgNavigationItemModel model) {
    return SdgNavigationItemEntity(
      goalId: model.goalId,
      title: model.title,
      imageAssetPath: model.imageAssetPath,
      // routeName: model.routeName,
    );
  }

  /// Retrieves a list of SDG (Sustainable Development Goals) navigation items.
  ///
  /// Fetches the items from the local data source and maps them to entities.
  /// Returns `null` if an error occurs during fetching or mapping.
  @override
  Future<List<SdgNavigationItemEntity>?> getSdgNavigationItems() async {
    try {
      final models = await localDataSource.getSdgNavigationItems();
      return models.map(_mapSdgModelToEntity).toList();
    } catch (e) {
      AppLogger.error("HomeRepositoryImpl: Error loading SDG navigation items", e);
      return null;
    }
  }

  /// Retrieves a stream of challenge previews based on a list of challenge IDs.
  ///
  /// Fetches challenge data from the remote data source, maps the documents
  /// to [ChallengePreviewEntity] objects, and limits the result.
  /// If [challengeIds] is empty, an empty list stream is returned.
  /// Returns a stream of `null` if an error occurs.
  @override
  Stream<List<ChallengePreviewEntity>?> getChallengesPreviewByIds({
    required List<String> challengeIds,
    required int limit,
  }) {
    if (challengeIds.isEmpty) return Stream.value([]);
    try {
      return remoteDataSource.getChallengesByIdsStream(challengeIds, limit).map((docs) {
        return docs.map(_mapDocumentToChallengePreview).take(limit).toList();
      }).handleError((error) {
        AppLogger.error("HomeRepositoryImpl: Error in getChallengesPreviewByIds stream", error);
        return null;
      });
    } catch (e) {
      AppLogger.error("HomeRepositoryImpl: Synchronous error in getChallengesPreviewByIds stream setup", e);
      return Stream.value(null);
    }
  }
}
