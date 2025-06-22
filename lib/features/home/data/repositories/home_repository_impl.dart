import 'package:cloud_firestore/cloud_firestore.dart'; // Für DocumentSnapshot
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/challenge_preview_entity.dart';
import '../../domain/entities/sdg_navigation_item_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/sdg_navigation_item_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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

  SdgNavigationItemEntity _mapSdgModelToEntity(SdgNavigationItemModel model) {
    return SdgNavigationItemEntity(
      goalId: model.goalId,
      title: model.title,
      imageAssetPath: model.imageAssetPath,
      // routeName: model.routeName,
    );
  }

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

  // In HomeRepositoryImpl
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