import 'package:flutter/foundation.dart';

@immutable
class GameBalanceModel {
  final int pointsPerCheckboxTask;
  final int pointsPerProvableTask;
  final int pointsPer1000Steps;
  final int maxTotalPoints;
  final int unlockedCheckboxPointsPerProvableTask;
  // This should be List<Map<String, dynamic>> to match the JSON
  final List<Map<String, dynamic>> difficultyThresholds;
  final List<Map<String, num>> groupChallengeMilestones;

  const GameBalanceModel({
    required this.pointsPerCheckboxTask,
    required this.pointsPerProvableTask,
    required this.pointsPer1000Steps,
    required this.maxTotalPoints,
    required this.unlockedCheckboxPointsPerProvableTask,
    required this.difficultyThresholds, // Type updated
    required this.groupChallengeMilestones,
  });

  factory GameBalanceModel.fromJson(Map<String, dynamic> json) {
    return GameBalanceModel(
      pointsPerCheckboxTask: json['points']['perCheckboxTask'] as int,
      pointsPerProvableTask: json['points']['perProvableTask'] as int,
      pointsPer1000Steps: json['points']['per1000Steps'] as int,
      maxTotalPoints: json['points']['maxTotalPoints'] as int,
      unlockedCheckboxPointsPerProvableTask: json['bonuses']['unlockedCheckboxPointsPerProvableTask'] as int,
      // CORRECTION: Correctly parse the list of maps as they are.
      difficultyThresholds: List<Map<String, dynamic>>.from(json['difficultyThresholds'] as List),
      // This line was correct, but the error above caused it to fail.
      groupChallengeMilestones: List<Map<String, num>>.from(
          (json['groupChallengeMilestones'] as List).map((item) => Map<String, num>.from(item))
      ),
    );
  }
}