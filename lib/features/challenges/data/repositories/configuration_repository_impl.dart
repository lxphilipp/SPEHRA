/// {@template configuration_repository_impl}
/// Implementation of the [ConfigurationRepository] interface.
/// {@endtemplate}
import '../../domain/entities/game_balance_entity.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../datasources/configuration_remote_datasource.dart';

/// {@macro configuration_repository_impl}
class ConfigurationRepositoryImpl implements ConfigurationRepository {
  /// The data source for fetching configuration data.
  final ConfigurationDataSource dataSource;

  /// {@macro configuration_repository_impl}
  ConfigurationRepositoryImpl({required this.dataSource});

  @override
  Future<GameBalanceEntity> getGameBalance() async {
    final model = await dataSource.getGameBalance();
    return GameBalanceEntity(
      pointsPerCheckboxTask: model.pointsPerCheckboxTask,
      pointsPerProvableTask: model.pointsPerProvableTask,
      pointsPer1000Steps: model.pointsPer1000Steps,
      maxTotalPoints: model.maxTotalPoints,
      unlockedCheckboxPointsPerProvableTask: model.unlockedCheckboxPointsPerProvableTask,
      difficultyThresholds: model.difficultyThresholds,
      groupChallengeMilestones: {
        for (var item in model.groupChallengeMilestones)
          (item['percentage'] as int): (item['bonusFactor'] as double)
      },
    );
  }
}
