import 'package:flutter/foundation.dart' show immutable, listEquals;

@immutable
class ChallengeEntity {
  final String id;
  final String title;
  final String description;
  final String task;
  final int points;
  final List<String> categories; // SDG-Goal-Keys
  final String difficulty;
  final DateTime? createdAt; // Optional, wenn vom Server gesetzt

  const ChallengeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.task,
    required this.points,
    required this.categories,
    required this.difficulty,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.task == task &&
        other.points == points &&
        listEquals(other.categories, categories) &&
        other.difficulty == difficulty &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, description, task, points,
      Object.hashAll(categories), difficulty, createdAt);

  ChallengeEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? task,
    int? points,
    List<String>? categories,
    String? difficulty,
    DateTime? createdAt,
  }) {
    return ChallengeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      task: task ?? this.task,
      points: points ?? this.points,
      categories: categories ?? this.categories,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}