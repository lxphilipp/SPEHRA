import 'package:flutter/foundation.dart' show immutable, listEquals;

@immutable
class UserProfileEntity {
  final String id;
  final String name;
  final String? email;
  final int age;
  final String studyField;
  final String school;
  final String? profileImageUrl;
  final int points;
  final int level;
  final List<String> ongoingTasks;
  final List<String> completedTasks;
  final bool hasCompletedIntro;

  const UserProfileEntity({
    required this.id,
    required this.name,
    this.email,
    required this.age,
    required this.studyField,
    required this.school,
    this.profileImageUrl,
    required this.points,
    required this.level,
    required this.completedTasks,
    required this.ongoingTasks,
    required this.hasCompletedIntro,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileEntity &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.age == age &&
        other.studyField == studyField &&
        other.school == school &&
        other.profileImageUrl == profileImageUrl &&
        other.points == points &&
        other.level == level &&
        listEquals(other.completedTasks, completedTasks) &&
        listEquals(other.ongoingTasks, ongoingTasks) &&
        other.hasCompletedIntro == hasCompletedIntro; // <-- NEU HINZUGEFÜGT
  }

  @override
  int get hashCode => Object.hash(
    id, name, email, age, studyField, school, profileImageUrl,
    points, level, Object.hashAll(completedTasks), Object.hashAll(ongoingTasks),
    hasCompletedIntro, // <-- NEU HINZUGEFÜGT
  );

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? studyField,
    String? school,
    String? profileImageUrl,
    int? points,
    int? level,
    List<String>? completedTasks,
    List<String>? ongoingTasks,
    bool? hasCompletedIntro,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      studyField: studyField ?? this.studyField,
      school: school ?? this.school,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      points: points ?? this.points,
      level: level ?? this.level,
      completedTasks: completedTasks ?? this.completedTasks,
      ongoingTasks: ongoingTasks ?? this.ongoingTasks,
      hasCompletedIntro: hasCompletedIntro ?? this.hasCompletedIntro,
    );
  }
}