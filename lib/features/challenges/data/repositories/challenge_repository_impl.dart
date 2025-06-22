import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_datasource.dart';
import '../models/challenge_model.dart';
// Für Timestamp

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDataSource remoteDataSource;

  ChallengeRepositoryImpl({required this.remoteDataSource});

  ChallengeEntity _mapModelToEntity(ChallengeModel model) {
    return ChallengeEntity(
      id: model.id!,
      title: model.title,
      description: model.description,
      task: model.task,
      points: model.points,
      categories: model.categories,
      difficulty: model.difficulty,
      createdAt: model.createdAt?.toDate(), // Timestamp zu DateTime
    );
  }

  @override
  Stream<List<ChallengeEntity>?> getAllChallengesStream() {
    return remoteDataSource.getAllChallengesStream().map((models) {
      return models.map(_mapModelToEntity).toList();
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
      return _mapModelToEntity(model);
    } catch (e) {
      AppLogger.error("ChallengeRepoImpl: Error in getChallengeById $challengeId", e);
      return null;
    }
  }

  @override
  Future<String?> createChallenge({
    required String title, required String description, required String task,
    required int points, required List<String> categories, required String difficulty,
  }) async {
    try {
      final newChallengeModel = ChallengeModel(
        title: title, description: description, task: task, points: points,
        categories: categories, difficulty: difficulty,
        // createdAt wird in toMap() automatisch gesetzt
      );
      final newId = await remoteDataSource.createChallenge(newChallengeModel);
      return newId;
    } catch (e) {
      AppLogger.error("ChallengeRepoImpl: Error in createChallenge", e);
      return null;
    }
  }
}