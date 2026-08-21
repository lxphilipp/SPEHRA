import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/game_balance_entity.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../datasources/configuration_remote_datasource.dart';
import '../models/game_balance_model.dart';

/// {@template configuration_repository_impl}
/// Implementation of the [ConfigurationRepository] interface.
///
/// Resolution order for the game balance:
/// 1. the remote Firestore document (operators can change it without
///    releasing a new app version),
/// 2. the JSON asset bundled with the app, if the remote document is missing
///    or cannot be read.
///
/// The resolved [GameBalanceEntity] is cached in memory for the lifetime of
/// the repository, so use cases can call [getGameBalance] freely without
/// triggering repeated reads. Concurrent first calls share one load.
/// {@endtemplate}
class ConfigurationRepositoryImpl implements ConfigurationRepository {
  /// Primary source (Firestore).
  final ConfigurationDataSource remoteDataSource;

  /// Fallback source (bundled asset).
  final ConfigurationDataSource localDataSource;

  GameBalanceEntity? _cached;
  Future<GameBalanceEntity>? _inFlight;

  /// {@macro configuration_repository_impl}
  ConfigurationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<GameBalanceEntity> getGameBalance({bool forceRefresh = false}) {
    if (!forceRefresh && _cached != null) {
      return Future.value(_cached);
    }
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<GameBalanceEntity> _load() async {
    GameBalanceModel model;
    try {
      model = await remoteDataSource.getGameBalance();
      AppLogger.info('Game balance loaded from remote configuration.');
    } catch (e) {
      AppLogger.warning(
        'Remote game balance unavailable ($e); falling back to bundled asset.',
      );
      model = await localDataSource.getGameBalance();
    }
    final entity = _toEntity(model);
    _cached = entity;
    return entity;
  }

  GameBalanceEntity _toEntity(GameBalanceModel model) {
    return GameBalanceEntity(
      pointsPerCheckboxTask: model.pointsPerCheckboxTask,
      pointsPerProvableTask: model.pointsPerProvableTask,
      pointsPer1000Steps: model.pointsPer1000Steps,
      maxTotalPoints: model.maxTotalPoints,
      unlockedCheckboxPointsPerProvableTask:
          model.unlockedCheckboxPointsPerProvableTask,
      difficultyThresholds: model.difficultyThresholds,
      groupChallengeMilestones: {
        for (final item in model.groupChallengeMilestones)
          (item['percentage'] as num).toInt(): (item['bonusFactor'] as num).toDouble(),
      },
      levelBaseXp: model.levelBaseXp,
      levelExponent: model.levelExponent,
    );
  }
}
