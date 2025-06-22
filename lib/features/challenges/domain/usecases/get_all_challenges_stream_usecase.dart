import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';

class GetAllChallengesStreamUseCase {
  final ChallengeRepository repository;
  GetAllChallengesStreamUseCase(this.repository);
  Stream<List<ChallengeEntity>?> call() => repository.getAllChallengesStream();
}