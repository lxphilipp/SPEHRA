import 'package:equatable/equatable.dart';

/// Represents the game balance settings.
///
/// This entity holds various point values and thresholds
/// that define the game's scoring and difficulty.
class GameBalanceEntity extends Equatable {
  /// Points awarded for completing a checkbox task.
  final int pointsPerCheckboxTask;

  /// Points awarded for completing a provable task.
  final int pointsPerProvableTask;

  /// Points awarded per 1000 steps taken.
  final int pointsPer1000Steps;

  /// The maximum total points a user can accumulate.
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
  /// The map keys represent the milestone number (e.g., 1, 2, 3)
  /// and the values represent the percentage of completion required
  /// to reach that milestone.
  final Map<int, double> groupChallengeMilestones;

  /// Creates a [GameBalanceEntity].
  const GameBalanceEntity({
    required this.pointsPerCheckboxTask,
    required this.pointsPerProvableTask,
    required this.pointsPer1000Steps,
    required this.maxTotalPoints,
    required this.unlockedCheckboxPointsPerProvableTask,
    required this.difficultyThresholds,
    required this.groupChallengeMilestones,
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
      ];
}
