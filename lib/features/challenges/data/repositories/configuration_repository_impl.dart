import '../../domain/entities/game_balance_entity.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../datasources/configuration_remote_datasource.dart';

class ConfigurationRepositoryImpl implements ConfigurationRepository {
  final ConfigurationDataSource dataSource;

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