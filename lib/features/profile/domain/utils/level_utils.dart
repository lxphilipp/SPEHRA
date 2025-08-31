import 'dart:math';
import 'package:flutter/foundation.dart';

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

/// A utility class for calculating user levels and progress based on a formula.
class LevelUtils {
  // --- Configuration for the leveling system ---
  /// Base XP needed to reach Level 2.
  static const int _baseXP = 1000;
  /// Controls how quickly the XP requirements increase with each level.
  static const double _exponent = 1.5;

  /// Calculates the **total** XP required to reach a specific `level`.
  ///
  /// Level 1 requires 0 XP.
  /// The formula used is: `baseXP * (level - 1) ^ exponent`.
  static int getXPForLevel(int level) {
    if (level <= 1) {
      return 0;
    }
    // Formula: Base XP * (Level - 1) ^ Exponent
    return (_baseXP * pow(level - 1, _exponent)).floor();
  }

  /// Calculates the current level based on the `totalPoints` accumulated by the user.
  static int calculateLevel(int totalPoints) {
    if (totalPoints < _baseXP) {
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
  static LevelData calculateLevelData(int totalPoints) {
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
