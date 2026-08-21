import 'package:flutter/foundation.dart' show immutable;

/// Represents a user profile with all its details.
@immutable
class UserProfileEntity {
  /// The unique identifier of the user.
  final String id;

  /// The name of the user.
  final String name;

  /// The email address of the user (optional).
  final String? email;

  /// The age of the user.
  final int age;

  /// The field of study of the user.
  final String studyField;

  /// The school or university of the user.
  final String school;

  /// The URL of the user's profile image (optional).
  final String? profileImageUrl;

  /// The total points accumulated by the user.
  final int points;

  /// The current level of the user.
  final int level;

  /// A flag indicating whether the user has completed the introductory flow.
  final bool hasCompletedIntro;

  /// Creates a [UserProfileEntity].
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
        other.hasCompletedIntro == hasCompletedIntro;
  }

  @override
  int get hashCode => Object.hash(
    id, name, email, age, studyField, school, profileImageUrl,
    points, level, hasCompletedIntro,
  );

  /// Creates a copy of this [UserProfileEntity] but with the given fields
  /// replaced with the new values.
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
      hasCompletedIntro: hasCompletedIntro ?? this.hasCompletedIntro,
    );
  }
}
