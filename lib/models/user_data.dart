// class UserData {
//   //
//   String? id;
//   // //String? name;
//   // String? email;
//   // String? about;
//   // String? image;
//   // String? createdAt;
//   // String? lastActived;
//   // String? pushToken;
//   // bool? online;
//   // List? myUsers;
//   //** */
//   String name;
//   int age;
//   String studyField;
//   String school;
//   String? imageURL;
//   List<String> completedTasks;
//   List<String> ongoingTasks;
//   int points;
//   int level;

//   UserData({
//     required this.name,
//     required this.age,
//     required this.studyField,
//     required this.school,
//     this.imageURL,
//     this.completedTasks = const [],
//     this.ongoingTasks = const [],
//     this.points = 0,
//     this.level = 1,
//   });

// // Convert UserData to a map for storing in Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'age': age,
//       'studyField': studyField,
//       'school': school,
//       'imageURL': imageURL,
//       'completedTasks': completedTasks,
//       'ongoingTasks': ongoingTasks,
//       'points': points,
//       'level': level,
//     };
//   }

//   // Create a UserData instance from a Firestore map
//   static UserData fromMap(Map<String, dynamic> map) {
//     return UserData(
//       name: map['name'] ?? '',
//       age: map['age'] ?? 0,
//       studyField: map['studyField'] ?? '',
//       school: map['school'] ?? '',
//       imageURL: map['imageURL'],
//       completedTasks: List<String>.from(map['completedTasks'] ?? []),
//       ongoingTasks: List<String>.from(map['ongoingTasks'] ?? []),
//       points: map['points'] ?? 0,
//       level: map['level'] ?? 1,
//     );
//   }
// }

class UserData {
  String? id;
  String? name;
  String? email;
  String? about;
  String? imageURL;
  String? createdAt;
  String? lastActived;
  String? pushToken;
  bool? online;
  List? myUsers;

  int? age;
  String? studyField;
  String? school;
  List<String>? completedTasks;
  List<String>? ongoingTasks;
  int? points;
  int? level;

  UserData({
    this.id,
    this.name,
    this.email,
    this.about,
    this.imageURL,
    this.createdAt,
    this.lastActived,
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
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      name: map['name'],
      email: map['email'] ?? map['eamil'], // احتمال تصحيح إملائي
      about: map['about'],
      imageURL: map['imageURL'] ?? map['image'],
      createdAt: map['created_At'],
      lastActived: map['last_Actived'],
      pushToken: map['pushToken'] ?? map['puch_Token'],
      online: map['online'],
      myUsers: map['my_users'],

      age: map['age'],
      studyField: map['studyField'],
      school: map['school'],
      completedTasks: List<String>.from(map['completedTasks'] ?? []),
      ongoingTasks: List<String>.from(map['ongoingTasks'] ?? []),
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'about': about,
      'imageURL': imageURL,
      'created_At': createdAt,
      'last_Actived': lastActived,
      'pushToken': pushToken,
      'online': online,
      'my_users': myUsers,
      'age': age,
      'studyField': studyField,
      'school': school,
      'completedTasks': completedTasks ?? [],
      'ongoingTasks': ongoingTasks ?? [],
      'points': points ?? 0,
      'level': level ?? 1,
    };
  }
}
