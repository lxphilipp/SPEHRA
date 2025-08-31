import 'package:flutter/foundation.dart' show immutable;

/// Represents a preview of a challenge, typically used in lists or overviews.
///
/// This entity contains essential information about a challenge,
/// such as its ID, title, difficulty, points, and categories.
@immutable
class ChallengePreviewEntity {
  /// The unique identifier of the challenge.
  final String id;

  /// The title of the challenge.
  final String title;

  /// The difficulty level of the challenge (e.g., "Easy", "Medium", "Hard").
  final String difficulty;

  /// The number of points awarded for completing the challenge.
  final int points;

  /// A list of category names associated with the challenge.
  final List<String> categories;

  /// Creates a [ChallengePreviewEntity].
  ///
  /// All parameters are required.
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
        listEquals(other.categories, categories);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      difficulty.hashCode ^
      points.hashCode ^
      Object.hashAll(categories);
}

/// Compares two lists for equality.
///
/// Returns `true` if both lists are `null`, or if they are both non-`null`,
/// have the same length, and contain the same elements in the same order.
/// Otherwise, returns `false`.
///
/// Type parameter:
///   <T>: The type of elements in the lists.
///
/// Parameters:
///   a: The first list.
///   b: The second list.
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