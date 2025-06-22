import '../repositories/challenge_repository.dart';

class CreateChallengeUseCase {
  final ChallengeRepository repository;
  CreateChallengeUseCase(this.repository);

  Future<String?> call(CreateChallengeParams params) => repository.createChallenge(
    title: params.title,
    description: params.description,
    task: params.task,
    points: params.points,
    categories: params.categories,
    difficulty: params.difficulty,
  );
}

class CreateChallengeParams {
  final String title;
  final String description;
  final String task;
  final int points;
  final List<String> categories;
  final String difficulty;

  CreateChallengeParams({
    required this.title,
    required this.description,
    required this.task,
    required this.points,
    required this.categories,
    required this.difficulty,
  });
}