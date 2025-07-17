import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/trackable_task.dart';

class ChallengeModel extends Equatable {
  final String? id;
  final String title;
  final String description;
  final List<String> categories;
  final String authorId;
  final Timestamp? createdAt;
  final List<Map<String, dynamic>> tasks;
  final Map<String, String>? llmFeedback;

  const ChallengeModel({
    this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.authorId,
    this.createdAt,
    required this.tasks,
    this.llmFeedback,
  });

  factory ChallengeModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categories: List<String>.from(data['category'] ?? []),
      authorId: data['authorId'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      tasks: List<Map<String, dynamic>>.from(data['tasks'] ?? []),
      llmFeedback: Map<String, String>.from(data['llmFeedback'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': categories,
      'authorId': authorId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'tasks': tasks,
      'llmFeedback': llmFeedback,
    };
  }

  factory ChallengeModel.fromEntity(ChallengeEntity entity) {
    return ChallengeModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      categories: entity.categories,
      authorId: entity.authorId,
      createdAt: entity.createdAt != null ? Timestamp.fromDate(entity.createdAt!) : null,
      tasks: entity.tasks.map((task) => _taskToMap(task)).toList(),
      llmFeedback: entity.llmFeedback,
    );
  }

  ChallengeEntity toEntity() {
    return ChallengeEntity(
      id: id ?? '',
      title: title,
      description: description,
      categories: categories,
      authorId: authorId,
      createdAt: createdAt?.toDate(),
      tasks: tasks.map((taskMap) => _mapToTask(taskMap)).toList(),
      llmFeedback: llmFeedback,
    );
  }

  @override
  List<Object?> get props => [id, title, description, categories, authorId, createdAt, tasks, llmFeedback];
}

// --- Helper functions for Task conversion ---

TrackableTask _mapToTask(Map<String, dynamic> map) {
  final type = map['type'];
  switch (type) {
    case 'checkbox':
      return CheckboxTask(description: map['description']);
    case 'step_counter':
    // It's good practice to do this for all numeric types
      return StepCounterTask(
          description: map['description'],
          targetSteps: (map['targetSteps'] as num).toInt());
    case 'location_visit':
      return LocationVisitTask(
          description: map['description'],
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          radius: (map['radius'] as num).toDouble());
    case 'image_upload':
      return ImageUploadTask(description: map['description']);
    default:
      throw Exception('Unknown Task Type: $type');
  }
}

Map<String, dynamic> _taskToMap(TrackableTask task) {
  if (task is CheckboxTask) {
    return {'type': 'checkbox', 'description': task.description};
  }
  if (task is StepCounterTask) {
    return {'type': 'step_counter', 'description': task.description, 'targetSteps': task.targetSteps};
  }
  if (task is LocationVisitTask) {
    return {'type': 'location_visit', 'description': task.description, 'latitude': task.latitude, 'longitude': task.longitude, 'radius': task.radius};
  }
  if (task is ImageUploadTask) {
    return {'type': 'image_upload', 'description': task.description};
  }
  throw Exception('Unknown Task-Type: ${task.runtimeType}');
}