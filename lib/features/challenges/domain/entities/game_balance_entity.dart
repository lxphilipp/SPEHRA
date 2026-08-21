import 'package:equatable/equatable.dart';

/// Represents the game balance settings.
///
/// This entity holds every tunable parameter of the motivational system:
/// point values per task type, bonus rules, difficulty thresholds, group
/// milestones and the shape of the level progression curve. It is loaded
/// through the [ConfigurationRepository] at runtime, so none of these values
/// are hard-coded in domain logic.
class GameBalanceEntity extends Equatable {
  /// Points awarded for completing a checkbox task.
  final int pointsPerCheckboxTask;

  /// Points awarded for completing a provable task.
  final int pointsPerProvableTask;

  /// Points awarded per 1000 steps taken.
  final int pointsPer1000Steps;

  /// The maximum total points a single challenge can award.
  final int maxTotalPoints;

  /// Points awarded for unlocked checkbox tasks per provable task.
  final int unlockedCheckboxPointsPerProvableTask;

  /// A list of difficulty thresholds.
  ///
  /// Each map in the list represents a difficulty level and its corresponding
  /// point threshold.
  final List<Map<String, dynamic>> difficultyThresholds;

  /// Milestones for group challenges.
  ///
  /// The map keys represent the percentage of completion required to reach
  /// the milestone and the values the bonus factor applied when it is reached.
  final Map<int, double> groupChallengeMilestones;

  /// Base experience points of the level curve: the total XP needed to reach
  /// level 2. Together with [levelExponent] it defines
  /// `xpForLevel(L) = levelBaseXp * (L - 1) ^ levelExponent`.
  final int levelBaseXp;

  /// Exponent of the level curve. Values above 1 make later levels
  /// progressively harder to reach.
  final double levelExponent;

  /// Creates a [GameBalanceEntity].
  const GameBalanceEntity({
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

  @override
  List<Object?> get props => [
        pointsPerCheckboxTask,
        pointsPerProvableTask,
        pointsPer1000Steps,
        maxTotalPoints,
        unlockedCheckboxPointsPerProvableTask,
        difficultyThresholds,
        groupChallengeMilestones,
        levelBaseXp,
        levelExponent,
      ];
}
