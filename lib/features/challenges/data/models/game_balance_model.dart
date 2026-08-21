import 'package:flutter/foundation.dart';

/// Represents the game balance settings as they are stored.
///
/// The same JSON shape is used for the bundled fallback asset
/// (`assets/data/game_balance_config.json`) and for the remote Firestore
/// document (`configuration/game_balance`), so the asset can be copied into
/// Firestore verbatim.
@immutable
class GameBalanceModel {
  /// Default base XP of the level curve, used when a stored document predates
  /// the `levelProgression` block.
  static const int defaultLevelBaseXp = 1000;

  /// Default exponent of the level curve, see [defaultLevelBaseXp].
  static const double defaultLevelExponent = 1.5;

  /// Points awarded for completing a checkbox task.
  final int pointsPerCheckboxTask;

  /// Points awarded for completing a provable task.
  final int pointsPerProvableTask;

  /// Points awarded per 1000 steps taken by the user.
  final int pointsPer1000Steps;

  /// The maximum total points a single challenge can award.
  final int maxTotalPoints;

  /// Bonus points awarded for each provable task when a checkbox task is unlocked.
  final int unlockedCheckboxPointsPerProvableTask;

  /// A list of difficulty thresholds, typically defining point ranges for different
  /// difficulty levels.
  final List<Map<String, dynamic>> difficultyThresholds;

  /// A list of milestones for group challenges, defining rewards or progression points.
  final List<Map<String, num>> groupChallengeMilestones;

  /// Base XP of the level progression curve (total XP needed for level 2).
  final int levelBaseXp;

  /// Exponent of the level progression curve.
  final double levelExponent;

  /// Creates a [GameBalanceModel].
  const GameBalanceModel({
    required this.pointsPerCheckboxTask,
    required this.pointsPerProvableTask,
    required this.pointsPer1000Steps,
    required this.maxTotalPoints,
    required this.unlockedCheckboxPointsPerProvableTask,
    required this.difficultyThresholds,
    required this.groupChallengeMilestones,
    required this.levelBaseXp,
    required this.levelExponent,
  });

  /// Creates a [GameBalanceModel] from a JSON object.
  ///
  /// The [json] parameter is a map representing the JSON object. The
  /// `levelProgression` block is optional and falls back to
  /// [defaultLevelBaseXp] / [defaultLevelExponent] when absent.
  factory GameBalanceModel.fromJson(Map<String, dynamic> json) {
    final points = json['points'] as Map<String, dynamic>;
    final bonuses = json['bonuses'] as Map<String, dynamic>;
    final levelProgression =
        (json['levelProgression'] as Map<String, dynamic>?) ?? const {};

    return GameBalanceModel(
      pointsPerCheckboxTask: (points['perCheckboxTask'] as num).toInt(),
      pointsPerProvableTask: (points['perProvableTask'] as num).toInt(),
      pointsPer1000Steps: (points['per1000Steps'] as num).toInt(),
      maxTotalPoints: (points['maxTotalPoints'] as num).toInt(),
      unlockedCheckboxPointsPerProvableTask:
          (bonuses['unlockedCheckboxPointsPerProvableTask'] as num).toInt(),
      difficultyThresholds: (json['difficultyThresholds'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      groupChallengeMilestones: (json['groupChallengeMilestones'] as List)
          .map((item) => Map<String, num>.from(item as Map))
          .toList(),
      levelBaseXp:
          (levelProgression['baseXp'] as num?)?.toInt() ?? defaultLevelBaseXp,
      levelExponent:
          (levelProgression['exponent'] as num?)?.toDouble() ?? defaultLevelExponent,
    );
  }

  /// Serialises the model back into the stored JSON shape.
  ///
  /// Used to seed the remote configuration document from the bundled asset.
  Map<String, dynamic> toJson() {
    return {
      'points': {
        'perCheckboxTask': pointsPerCheckboxTask,
        'perProvableTask': pointsPerProvableTask,
        'per1000Steps': pointsPer1000Steps,
        'maxTotalPoints': maxTotalPoints,
      },
      'bonuses': {
        'unlockedCheckboxPointsPerProvableTask': unlockedCheckboxPointsPerProvableTask,
      },
      'difficultyThresholds': difficultyThresholds,
      'groupChallengeMilestones': groupChallengeMilestones,
      'levelProgression': {
        'baseXp': levelBaseXp,
        'exponent': levelExponent,
      },
    };
  }
}
