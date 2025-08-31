import 'package:latlong2/latlong.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/trackable_task.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_datasource.dart';
import '../models/challenge_model.dart';

/// Implementation of the [ChallengeRepository] interface.
///
/// This class interacts with the [ChallengeRemoteDataSource] to fetch and manage
/// challenge data.
class ChallengeRepositoryImpl implements ChallengeRepository {
  /// The remote data source for challenges.
  final ChallengeRemoteDataSource remoteDataSource;

  /// Creates a [ChallengeRepositoryImpl].
  ///
  /// Requires a [remoteDataSource] to interact with the remote server.
  ChallengeRepositoryImpl({required this.remoteDataSource});

  /// Maps a [ChallengeModel] to a [ChallengeEntity].
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
      final challengeModel = ChallengeModel.fromEntity(challengeData);
      final fullChallengeJson = challengeModel.toMap();

      return await remoteDataSource.fetchLlmFeedback(
        step: step,
        challengeJson: fullChallengeJson,
      );
    } catch (e) {
      AppLogger.error("ChallengeRepoImpl: Error getting LLM feedback", e);
      return null;
    }
  }

  @override
  Future<List<AddressEntity>> searchLocation(String query) async {
    // 1. Fetch data from the DataSource as a pure data model
    final addressModels = await remoteDataSource.searchLocation(query);

    // 2. HERE THE TRANSLATION HAPPENS: Model -> Entity
    return addressModels.map((model) => AddressEntity(
      displayName: model.displayName,
      point: LatLng(model.latitude, model.longitude),
    )).toList();
  }
}
