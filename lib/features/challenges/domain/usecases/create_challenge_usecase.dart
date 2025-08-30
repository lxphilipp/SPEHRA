import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/trackable_task.dart';
import '../repositories/challenge_repository.dart';

/// This Use Case encapsulates the logic for creating a new Challenge.
/// It takes the necessary parameters and forwards them to the repository.
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

/// A data container object that bundles the parameters for creating a challenge.
/// This makes the code cleaner and more readable than a long list of parameters.
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