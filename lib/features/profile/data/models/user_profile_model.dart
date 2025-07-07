
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;

@immutable
class UserProfileModel {
  final String id;
  final String name;
  final String? email;
  final int age;
  final String studyField;
  final String school;
  final String? imageURL;
  final int points;
  final int level;
  final List<String> ongoingTasks;
  final List<String> completedTasks;
  final DateTime? createdAt;

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
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Robust parsing for numbers
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
      // CORRECTED: Fallback to null instead of DateTime.now()
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a map for partial updates.
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'age': age,
      'studyField': studyField,
      'school': school,
      // By not having an `if`, this allows setting the imageURL to null.
      'imageURL': imageURL,
    };
  }

  /// Creates a map containing all data, suitable for creating a new document.
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
      // CORRECTED: Explicitly use Timestamp.fromDate for writing to Firestore
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

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
    // CORRECTED: Parameter type changed from String? to DateTime?
    DateTime? createdAt,
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
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id, name, email, age, studyField, school, imageURL,
    points, level,
    // Hashing the lists like this is robust.
    Object.hashAll(ongoingTasks),
    Object.hashAll(completedTasks),
    createdAt,
  );
}