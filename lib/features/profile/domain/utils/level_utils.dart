import 'dart:math';
import 'package:flutter/foundation.dart';

/// Hält die berechneten Daten für das aktuelle Level eines Nutzers.
@immutable
class LevelData {
  final int level;
  final double progress; // Ein Wert zwischen 0.0 und 1.0
  final int pointsForNextLevel;
  final int startPointsOfCurrentLevel;

  const LevelData({
    required this.level,
    required this.progress,
    required this.pointsForNextLevel,
    required this.startPointsOfCurrentLevel,
  });
}

/// Eine Hilfsklasse zur Berechnung von Level und Fortschritt mithilfe einer Formel.
class LevelUtils {
  // --- Konfiguration für das Level-System ---
  static const int _baseXP = 1000;      // XP benötigt für Level 2
  static const double _exponent = 1.5; // Steuert, wie schnell die XP-Anforderungen steigen

  /// Berechnet die **totalen** XP, die man braucht, um Level `level` zu erreichen.
  /// Level 1 benötigt 0 XP.
  static int getXPForLevel(int level) {
    if (level <= 1) {
      return 0;
    }
    // Formel: Basis-XP * (Level - 1) ^ Exponent
    return (_baseXP * pow(level - 1, _exponent)).floor();
  }

  /// Berechnet das aktuelle Level basierend auf den Gesamtpunkten.
  static int calculateLevel(int totalPoints) {
    if (totalPoints < _baseXP) {
      return 1;
    }

    int level = 1;

    while (true) {
      final xpForNextLevel = getXPForLevel(level + 1);
      if (xpForNextLevel > totalPoints) {
        break;
      }
      level++;
    }
    return level;
  }

  /// Berechnet alle relevanten Daten (Level, Fortschritt, etc.)
  static LevelData calculateLevelData(int totalPoints) {
    final int currentLevel = calculateLevel(totalPoints);

    final int startPointsOfCurrentLevel = getXPForLevel(currentLevel);
    final int pointsForNextLevel = getXPForLevel(currentLevel + 1);

    // Die Differenz an Punkten, die man für das aktuelle Level-up braucht
    final int pointsNeededForLevelUp = pointsForNextLevel - startPointsOfCurrentLevel;
    // Die Punkte, die man im aktuellen Level bereits gesammelt hat
    final int pointsInCurrentLevel = totalPoints - startPointsOfCurrentLevel;

    double progress = (pointsNeededForLevelUp > 0)
        ? (pointsInCurrentLevel / pointsNeededForLevelUp)
        : 1.0;

    return LevelData(
      level: currentLevel,
      progress: progress.clamp(0.0, 1.0),
      pointsForNextLevel: pointsForNextLevel,
      startPointsOfCurrentLevel: startPointsOfCurrentLevel,
    );
  }
}