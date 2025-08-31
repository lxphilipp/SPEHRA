import '../entities/game_balance_entity.dart';

/// Abstract class for managing configuration settings.
abstract class ConfigurationRepository {
  /// Retrieves the game balance configuration.
  ///
  /// Returns a [Future] that completes with a [GameBalanceEntity] object.
  Future<GameBalanceEntity> getGameBalance();
}
