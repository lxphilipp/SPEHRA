import 'package:latlong2/latlong.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/trackable_task.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_datasource.dart';
import '../models/challenge_model.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDataSource remoteDataSource;

  ChallengeRepositoryImpl({required this.remoteDataSource});

  ChallengeEntity _mapModelToEntity(ChallengeModel model) {
    return model.toEntity();
  }

  @override
  Stream<List<ChallengeEntity>?> getAllChallengesStream() {
    return remoteDataSource.getAllChallengesStream().map((models) {
      return models.map((model) => model.toEntity()).toList();
    }).handleError((error) {
      AppLogger.error("ChallengeRepoImpl: Error in getAllChallengesStream", error);
      return null;
    });
  }

  @override
  Future<ChallengeEntity?> getChallengeById(String challengeId) async {
    try {
      final model = await remoteDataSource.getChallengeById(challengeId);
      if (model == null) return null;
      return model.toEntity();
    } catch (e) {
      AppLogger.error("ChallengeRepoImpl: Error in getChallengeById $challengeId", e);
      return null;
    }
  }

  @override
  Future<String?> createChallenge({
    required String title,
    required String description,
    required List<String> categories,
    required String authorId,
    required List<TrackableTask> tasks,
    Map<String, String>? llmFeedback,
  }) async {
    try {
      final tempEntity = ChallengeEntity(
        id: '',
        title: title,
        description: description,
        categories: categories,
        authorId: authorId,
        tasks: tasks,
        llmFeedback: llmFeedback,
      );

      final newChallengeModel = ChallengeModel.fromEntity(tempEntity);

      final newId = await remoteDataSource.createChallenge(newChallengeModel);
      return newId;
    } catch (e) {
      AppLogger.error("ChallengeRepoImpl: Error in createChallenge", e);
      return null;
    }
  }

  @override
  Future<String?> getLlmFeedback({
    required String step,
    required ChallengeEntity challengeData,
  }) async {
    try {
      final challengeJson = {
        'title': challengeData.title,
        'description': challengeData.description,
        'categories': challengeData.categories,
      };

      // Und übergeben nur noch diese einfache Map an die DataSource
      return await remoteDataSource.fetchLlmFeedback(
        step: step,
        challengeJson: challengeJson,
      );
    } catch (e) {
      AppLogger.error("ChallengeRepoImpl: Error getting LLM feedback", e);
      return null;
    }
  }

  @override
  Future<List<AddressEntity>> searchLocation(String query) async {
    // 1. Daten von der DataSource als reines Daten-Model holen
    final addressModels = await remoteDataSource.searchLocation(query);

    // 2. HIER PASSIERT DIE ÜBERSETZUNG: Model -> Entity
    return addressModels.map((model) => AddressEntity(
      displayName: model.displayName,
      point: LatLng(model.latitude, model.longitude),
    )).toList();
  }
}