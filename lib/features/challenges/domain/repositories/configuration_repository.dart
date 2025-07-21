import '../entities/game_balance_entity.dart';

abstract class ConfigurationRepository {
  Future<GameBalanceEntity> getGameBalance();
}