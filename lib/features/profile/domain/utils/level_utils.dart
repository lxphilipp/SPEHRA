import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../challenges/domain/entities/game_balance_entity.dart';

/// Holds the calculated data for a user's current level.
@immutable
class LevelData {
  /// The current level of the user.
  final int level;

  /// The progress towards the next level, as a value between 0.0 and 1.0.
  final double progress;

  /// The total experience points (XP) needed to reach the next level.
  final int pointsForNextLevel;

  /// The total experience points (XP) that marked the beginning of the current level.
  final int startPointsOfCurrentLevel;

  /// Creates an instance of [LevelData].
  ///
  /// All parameters are required.
  const LevelData({
    required this.level,
    required this.progress,
    required this.pointsForNextLevel,
    required this.startPointsOfCurrentLevel,
  });
}

/// Calculates user levels and progress from a power-law progression curve.
///
/// The curve is `xpForLevel(L) = baseXp * (L - 1) ^ exponent`, so with an
/// exponent above 1 early levels arrive quickly while later levels stretch
/// out. Both parameters come from the [GameBalanceEntity] (see
/// [LevelUtils.fromBalance]), i.e. operators can reshape the curve through the
/// balance configuration without touching this class.
@immutable
class LevelUtils {
  /// Total XP needed to reach level 2.
  final int baseXp;

  /// Controls how quickly the XP requirements increase with each level.
  final double exponent;

  /// Creates a level calculator with explicit curve parameters.
  ///
  /// [baseXp] must be positive and [exponent] must be greater than 0,
  /// otherwise the level search would not terminate.
  const LevelUtils({required this.baseXp, required this.exponent})
      : assert(baseXp > 0, 'baseXp must be positive'),
        assert(exponent > 0, 'exponent must be positive');

  /// Creates a level calculator from the curve parameters of [balance].
  factory LevelUtils.fromBalance(GameBalanceEntity balance) {
    return LevelUtils(
      baseXp: balance.levelBaseXp,
      exponent: balance.levelExponent,
    );
  }

  /// Calculates the **total** XP required to reach a specific `level`.
  ///
  /// Level 1 requires 0 XP.
  /// The formula used is: `baseXp * (level - 1) ^ exponent`.
  int getXPForLevel(int level) {
    if (level <= 1) {
      return 0;
    }
    return (baseXp * pow(level - 1, exponent)).floor();
  }

  /// Calculates the current level based on the `totalPoints` accumulated by the user.
  int calculateLevel(int totalPoints) {
    if (totalPoints < baseXp) {
      return 1; // User is Level 1 if they haven't reached the XP for Level 2.
    }

    int level = 1;

    // Iteratively check levels until the XP for the next level exceeds totalPoints.
    while (true) {
      final xpForNextLevel = getXPForLevel(level + 1);
      if (xpForNextLevel > totalPoints) {
        break; // Current level found.
      }
      level++;
    }
    return level;
  }

  /// Calculates all relevant data for the current level (level, progress, etc.)
  /// based on the `totalPoints` accumulated by the user.
  LevelData calculateLevelData(int totalPoints) {
    final int currentLevel = calculateLevel(totalPoints);

    final int startPointsOfCurrentLevel = getXPForLevel(currentLevel);
    final int pointsForNextLevel = getXPForLevel(currentLevel + 1);

    // The difference in points needed for the current level-up.
    final int pointsNeededForLevelUp = pointsForNextLevel - startPointsOfCurrentLevel;
    // The points already accumulated within the current level.
    final int pointsInCurrentLevel = totalPoints - startPointsOfCurrentLevel;

    // Calculate progress, ensuring it's 1.0 if no more points are needed (e.g., max level).
    double progress = (pointsNeededForLevelUp > 0)
        ? (pointsInCurrentLevel / pointsNeededForLevelUp)
        : 1.0;

    return LevelData(
      level: currentLevel,
      progress: progress.clamp(0.0, 1.0), // Ensure progress is between 0.0 and 1.0.
      pointsForNextLevel: pointsForNextLevel,
      startPointsOfCurrentLevel: startPointsOfCurrentLevel,
    );
  }
}
