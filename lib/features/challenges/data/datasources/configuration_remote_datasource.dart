import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/game_balance_model.dart';

abstract class ConfigurationDataSource {
  Future<GameBalanceModel> getGameBalance();
}

class ConfigurationDataSourceImpl implements ConfigurationDataSource {
  final String _configPath = 'assets/data/game_balance_config.json';

  @override
  Future<GameBalanceModel> getGameBalance() async {
    final jsonString = await rootBundle.loadString(_configPath);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return GameBalanceModel.fromJson(jsonMap);
  }
}