import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Represents a user's profile information.
@immutable
class UserProfileModel {
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

  /// The school or university the user attends.
  final String school;

  /// The URL of the user's profile image (optional).
  final String? imageURL;

  /// The points accumulated by the user.
  final int points;

  /// The current level of the user.
  final int level;

  /// A list of IDs of tasks currently in progress by the user.
  final List<String> ongoingTasks;

  /// A list of IDs of tasks completed by the user.
  final List<String> completedTasks;

  /// The date and time when the user profile was created (optional).
  final DateTime? createdAt;

  /// Indicates whether the user has completed the introductory flow.
  final bool hasCompletedIntro;

  /// Creates a [UserProfileModel] instance.
  const UserProfileModel({
    required this.id,
    required this.name,
    this.email,
    required this.age,
    required this.studyField,
    required this.school,
    this.imageURL,
    required this.points,
    required this.level,
    required this.ongoingTasks,
    required this.completedTasks,
    this.createdAt,
    required this.hasCompletedIntro,
  });

  /// Creates a [UserProfileModel] instance from a Firestore document map.
  ///
  /// [map] is a map of data from Firestore.
  /// [documentId] is the ID of the Firestore document.
  factory UserProfileModel.fromMap(Map<String, dynamic> map, String documentId) {
    final ageNum = map['age'] as num?;
    final pointsNum = map['points'] as num?;
    final levelNum = map['level'] as num?;

    return UserProfileModel(
      id: documentId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String?,
      age: ageNum?.toInt() ?? 0,
      studyField: map['studyField'] as String? ?? '',
      school: map['school'] as String? ?? '',
      imageURL: map['imageURL'] as String?,
      points: pointsNum?.toInt() ?? 0,
      level: levelNum?.toInt() ?? 1,
      ongoingTasks: List<String>.from(map['ongoingTasks'] ?? []),
      completedTasks: List<String>.from(map['completedTasks'] ?? []),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      hasCompletedIntro: map['hasCompletedIntro'] as bool? ?? false,
    );
  }

  /// Converts the [UserProfileModel] to a map for updating Firestore.
  ///
  /// This map includes only the fields that are typically updated by the user.
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'age': age,
      'studyField': studyField,
      'school': school,
      'imageURL': imageURL,
    };
  }

  /// Converts the [UserProfileModel] to a full map for Firestore.
  ///
  /// This map includes all fields of the user profile.
  Map<String, dynamic> toFullMap() {
    return {
      'name': name,
      if (email != null) 'email': email,
      'age': age,
      'studyField': studyField,
      'school': school,
      'imageURL': imageURL,
      'points': points,
      'level': level,
      'ongoingTasks': ongoingTasks,
      'completedTasks': completedTasks,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'hasCompletedIntro': hasCompletedIntro,
    };
  }

  /// Creates a copy of this [UserProfileModel] but with the given fields replaced
  /// with the new values.
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? studyField,
    String? school,
    String? imageURL,
    bool setImageToNull = false,
    int? points,
    int? level,
    List<String>? ongoingTasks,
    List<String>? completedTasks,
    DateTime? createdAt,
    bool? hasCompletedIntro,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      studyField: studyField ?? this.studyField,
      school: school ?? this.school,
      imageURL: setImageToNull ? null : (imageURL ?? this.imageURL),
      points: points ?? this.points,
      level: level ?? this.level,
      ongoingTasks: ongoingTasks ?? this.ongoingTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      createdAt: createdAt ?? this.createdAt,
      hasCompletedIntro: hasCompletedIntro ?? this.hasCompletedIntro,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.age == age &&
        other.studyField == studyField &&
        other.school == school &&
        other.imageURL == imageURL &&
        other.points == points &&
        other.level == level &&
        listEquals(other.ongoingTasks, ongoingTasks) &&
        listEquals(other.completedTasks, completedTasks) &&
        other.createdAt == createdAt &&
        other.hasCompletedIntro == hasCompletedIntro;
  }

  @override
  int get hashCode => Object.hash(
    id, name, email, age, studyField, school, imageURL,
    points, level,
    Object.hashAll(ongoingTasks),
    Object.hashAll(completedTasks),
    createdAt,
    hasCompletedIntro,
  );
}
