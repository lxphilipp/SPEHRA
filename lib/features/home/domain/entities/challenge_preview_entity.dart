import 'package:flutter/foundation.dart' show immutable;

@immutable
class ChallengePreviewEntity {
  final String id;
  final String title;
  final String difficulty; // oder ein Enum
  final int points;
  final List<String> categories; // SDG-Goal-Keys (z.B. ["goal1", "goal5"])

  const ChallengePreviewEntity({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.points,
    required this.categories,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengePreviewEntity &&
        other.id == id &&
        other.title == title &&
        other.difficulty == difficulty &&
        other.points == points &&
        // Wichtig für Listenvergleich: listEquals oder DeepCollectionEquality
        listEquals(other.categories, categories);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      difficulty.hashCode ^
      points.hashCode ^
      Object.hashAll(categories); // Korrekter Hash für Listen
}

// Hilfsfunktion für Listenvergleich (oder nutze das `collection`-Paket)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}