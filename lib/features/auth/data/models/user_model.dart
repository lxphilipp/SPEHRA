import 'package:cloud_firestore/cloud_firestore.dart';

/// A model representing a user in the application.
class UserModel {
  /// The unique identifier of the user.
  String? id;

  /// The name of the user.
  String? name;

  /// The email address of the user.
  String? email;

  /// A short bio or description about the user.
  String? about;

  /// The URL of the user's profile image.
  String? imageURL;

  /// The date and time when the user account was created.
  DateTime? createdAt;

  /// The date and time when the user was last active.
  DateTime? lastActiveAt;

  /// The push notification token for the user's device.
  String? pushToken;

  /// A flag indicating whether the user is currently online.
  bool? online;

  /// A list of user IDs that this user is connected to.
  List<String>? myUsers;

  /// The age of the user.
  int? age;

  /// The user's field of study.
  String? studyField;

  /// The school or university the user attends.
  String? school;

  /// A list of task IDs that the user has completed.
  List<String>? completedTasks;

  /// A list of task IDs that the user is currently working on.
  List<String>? ongoingTasks;

  /// The total points accumulated by the user.
  int? points;

  /// The current level of the user in the gamification system.
  int? level;

  /// A flag indicating whether the user has completed the introductory flow.
  bool? hasCompletedIntro;

  /// Creates a [UserModel] instance.
  UserModel({
    this.id,
    this.name,
    this.email,
    this.about,
    this.imageURL,
    this.createdAt,
    this.lastActiveAt,
    this.pushToken,
    this.online,
    this.myUsers,
    this.age,
    this.studyField,
    this.school,
    this.completedTasks = const [],
    this.ongoingTasks = const [],
    this.points = 0,
    this.level = 1,
    this.hasCompletedIntro = false,
  });

  /// Creates a [UserModel] from a map of data.
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    String? emptyToNull(dynamic value) {
      if (value is String && value.isEmpty) {
        return null;
      }
      return value as String?;
    }

    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        final asInt = int.tryParse(value);
        if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateTime.tryParse(value);
      }
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return UserModel(
      id: docId,
      name: map['name'] as String?,
      email: map['email'] as String? ?? map['eamil'] as String?,
      about: emptyToNull(map['about']),
      imageURL: emptyToNull(map['imageURL'] ?? map['image']),
      createdAt: parseTimestamp(map['createdAt'] ?? map['created_At']),
      lastActiveAt: parseTimestamp(map['lastActiveAt'] ?? map['last_Actived']),
      pushToken: emptyToNull(map['pushToken'] ?? map['puch_Token']),
      online: map['online'] as bool?,
      myUsers: List<String>.from(map['my_users'] as List<dynamic>? ?? []),
      age: (map['age'] as num?)?.toInt(),
      studyField: map['studyField'] as String?,
      school: map['school'] as String?,
      completedTasks: List<String>.from(map['completedTasks'] as List<dynamic>? ?? []),
      ongoingTasks: List<String>.from(map['ongoingTasks'] as List<dynamic>? ?? []),
      points: (map['points'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      hasCompletedIntro: map['hasCompletedIntro'] as bool? ?? false,
    );
  }

  /// Converts the [UserModel] to a map of data.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'about': about,
      'imageURL': imageURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'pushToken': pushToken,
      'online': online,
      'my_users': myUsers,
      'age': age,
      'studyField': studyField,
      'school': school,
      'completedTasks': completedTasks,
      'ongoingTasks': ongoingTasks,
      'points': points,
      'level': level,
      'hasCompletedIntro': hasCompletedIntro,
    };
  }
}