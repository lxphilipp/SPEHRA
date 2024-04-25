class UserData {
  String name;
  int age;
  String studyField;
  String school;
  String? imageURL;
  List<String> completedTasks;
  List<String> ongoingTasks;
  int points;
  int level;

  UserData({
    required this.name,
    required this.age,
    required this.studyField,
    required this.school,
    this.imageURL,
    this.completedTasks = const [],
    this.ongoingTasks = const [],
    this.points = 0,
    this.level = 1,
  });

// Convert UserData to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'studyField': studyField,
      'school': school,
      'imageURL': imageURL,
      'completedTasks': completedTasks,
      'ongoingTasks': ongoingTasks,
      'points': points,
      'level': level,
    };
  }

  // Create a UserData instance from a Firestore map
  static UserData fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      studyField: map['studyField'] ?? '',
      school: map['school'] ?? '',
      imageURL: map['imageURL'],
      completedTasks: List<String>.from(map['completedTasks'] ?? []),
      ongoingTasks: List<String>.from(map['ongoingTasks'] ?? []),
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
    );
  }
}
