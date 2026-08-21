import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import '../models/game_balance_model.dart';
import 'configuration_remote_datasource.dart' show ConfigurationDataSource;

/// Implementation of [ConfigurationDataSource] that reads the game balance
/// from the JSON asset bundled with the app.
///
/// This is the fallback used when the remote document is unavailable (first
/// start without network, missing document, missing read permission). It is
/// also the template for the remote document: both share the same JSON shape.
class ConfigurationLocalDataSourceImpl implements ConfigurationDataSource {
  /// The path to the local JSON asset containing the game balance configuration.
  static const String configPath = 'assets/data/game_balance_config.json';

  final AssetBundle _bundle;

  /// Creates a [ConfigurationLocalDataSourceImpl].
  ///
  /// [bundle] defaults to [rootBundle]; tests can inject their own.
  ConfigurationLocalDataSourceImpl({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  @override
  Future<GameBalanceModel> getGameBalance() async {
    final jsonString = await _bundle.loadString(configPath);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return GameBalanceModel.fromJson(jsonMap);
  }
}
