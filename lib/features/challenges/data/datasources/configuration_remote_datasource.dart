import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/game_balance_model.dart';

/// Abstract class for fetching configuration data.
abstract class ConfigurationDataSource {
  /// Fetches the game balance configuration.
  ///
  /// Returns a [Future] that completes with a [GameBalanceModel].
  Future<GameBalanceModel> getGameBalance();
}

/// Implementation of [ConfigurationDataSource] that fetches data from a local JSON asset.
class ConfigurationDataSourceImpl implements ConfigurationDataSource {
  /// The path to the local JSON asset containing the game balance configuration.
  final String _configPath = 'assets/data/game_balance_config.json';

  @override
  Future<GameBalanceModel> getGameBalance() async {
    final jsonString = await rootBundle.loadString(_configPath);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return GameBalanceModel.fromJson(jsonMap);
  }
}
