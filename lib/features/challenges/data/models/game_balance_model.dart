import 'package:flutter/foundation.dart';

/// Represents the game balance settings.
///
/// This model defines various point allocations, thresholds, and milestones
/// used within the game's mechanics.
@immutable
class GameBalanceModel {
  /// Points awarded for completing a checkbox task.
  final int pointsPerCheckboxTask;

  /// Points awarded for completing a provable task.
  final int pointsPerProvableTask;

  /// Points awarded per 1000 steps taken by the user.
  final int pointsPer1000Steps;

  /// The maximum total points a user can accumulate.
  final int maxTotalPoints;

  /// Bonus points awarded for each provable task when a checkbox task is unlocked.
  final int unlockedCheckboxPointsPerProvableTask;

  /// A list of difficulty thresholds, typically defining point ranges for different
  /// difficulty levels.
  final List<Map<String, dynamic>> difficultyThresholds;

  /// A list of milestones for group challenges, defining rewards or progression points.
  final List<Map<String, num>> groupChallengeMilestones;

  /// Creates a [GameBalanceModel].
  const GameBalanceModel({
    required this.pointsPerCheckboxTask,
    required this.pointsPerProvableTask,
    required this.pointsPer1000Steps,
    required this.maxTotalPoints,
    required this.unlockedCheckboxPointsPerProvableTask,
    required this.difficultyThresholds,
    required this.groupChallengeMilestones,
  });

  /// Creates a [GameBalanceModel] from a JSON object.
  ///
  /// The [json] parameter is a map representing the JSON object.
  factory GameBalanceModel.fromJson(Map<String, dynamic> json) {
    return GameBalanceModel(
      pointsPerCheckboxTask: json['points']['perCheckboxTask'] as int,
      pointsPerProvableTask: json['points']['perProvableTask'] as int,
      pointsPer1000Steps: json['points']['per1000Steps'] as int,
      maxTotalPoints: json['points']['maxTotalPoints'] as int,
      unlockedCheckboxPointsPerProvableTask: json['bonuses']['unlockedCheckboxPointsPerProvableTask'] as int,
      difficultyThresholds: List<Map<String, dynamic>>.from(json['difficultyThresholds'] as List),
      groupChallengeMilestones: List<Map<String, num>>.from(
          (json['groupChallengeMilestones'] as List).map((item) => Map<String, num>.from(item))
      ),
    );
  }
}