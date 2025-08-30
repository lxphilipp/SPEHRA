import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? about;
  String? imageURL;
  DateTime? createdAt;
  DateTime? lastActiveAt;
  String? pushToken;
  bool? online;
  List<String>? myUsers;

  int? age;
  String? studyField;
  String? school;
  List<String>? completedTasks;
  List<String>? ongoingTasks;
  int? points;
  int? level;
  bool? hasCompletedIntro;

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