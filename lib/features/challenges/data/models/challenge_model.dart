import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/trackable_task.dart';

/// Represents the data model for a challenge, extending [Equatable] for value equality.
/// This model is used for interacting with Firestore and converting to/from [ChallengeEntity].
class ChallengeModel extends Equatable {
  /// The unique identifier of the challenge.
  final String? id;
  /// The title of the challenge.
  final String title;
  /// A description of the challenge.
  final String description;
  /// A list of categories the challenge belongs to.
  final List<String> categories;
  /// The identifier of the author of the challenge.
  final String authorId;
  /// The timestamp when the challenge was created.
  final Timestamp? createdAt;
  /// A list of tasks associated with the challenge, stored as maps.
  final List<Map<String, dynamic>> tasks;
  /// Optional feedback from an LLM related to the challenge.
  final Map<String, String>? llmFeedback;

  /// Creates a [ChallengeModel] instance.
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

  /// Creates a [ChallengeModel] instance from a Firestore [DocumentSnapshot].
  factory ChallengeModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categories: List<String>.from(data['categories'] ?? data['category'] ?? []),
      authorId: data['authorId'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      tasks: List<Map<String, dynamic>>.from(data['tasks'] ?? []),
      llmFeedback: Map<String, String>.from(data['llmFeedback'] ?? {}),
    );
  }

  /// Converts this [ChallengeModel] instance to a [Map] for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'categories': categories,
      'authorId': authorId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'tasks': tasks,
      'llmFeedback': llmFeedback,
    };
  }

  /// Creates a [ChallengeModel] instance from a [ChallengeEntity].
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

  /// Converts this [ChallengeModel] instance to a [ChallengeEntity].
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

// --- Helper functions for Task conversion (unchanged) ---

/// Converts a [Map] representation of a task to a [TrackableTask] instance.
///
/// Throws an [Exception] if the task type is unknown.
TrackableTask _mapToTask(Map<String, dynamic> map) {
  final type = map['type'];
  switch (type) {
    case 'checkbox':
      return CheckboxTask(description: map['description']);
    case 'step_counter':
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

/// Converts a [TrackableTask] instance to a [Map] representation.
///
/// Throws an [Exception] if the task type is unknown.
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
