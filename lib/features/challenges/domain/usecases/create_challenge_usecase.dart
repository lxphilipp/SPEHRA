import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/trackable_task.dart'; // Wichtig: Import der neuen Tasks
import '../repositories/challenge_repository.dart';

/// Dieser Use Case kapselt die Logik zum Erstellen einer neuen Challenge.
/// Er nimmt die notwendigen Parameter entgegen und leitet sie an das Repository weiter.
class CreateChallengeUseCase implements UseCase<String?, CreateChallengeParams> {
  final ChallengeRepository repository;

  CreateChallengeUseCase(this.repository);

  @override
  Future<String?> call(CreateChallengeParams params) async {

    return await repository.createChallenge(
      title: params.title,
      description: params.description,
      categories: params.categories,
      authorId: params.authorId,
      tasks: params.tasks,
      llmFeedback: params.llmFeedback,
    );
  }
}

/// Ein Daten-Container-Objekt, das die Parameter für die Erstellung einer Challenge bündelt.
/// Dies macht den Code sauberer und besser lesbar als eine lange Liste von Parametern.
class CreateChallengeParams extends Equatable {
  final String title;
  final String description;
  final List<String> categories;
  final String authorId;
  final List<TrackableTask> tasks;
  final Map<String, String>? llmFeedback;

  const CreateChallengeParams({
    required this.title,
    required this.description,
    required this.categories,
    required this.authorId,
    required this.tasks,
    this.llmFeedback,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    categories,
    authorId,
    tasks,
    llmFeedback,
  ];
}