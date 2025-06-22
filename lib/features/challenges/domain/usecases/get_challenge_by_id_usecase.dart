import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';

class GetChallengeByIdUseCase {
  final ChallengeRepository repository;
  GetChallengeByIdUseCase(this.repository);
  Future<ChallengeEntity?> call(String challengeId) => repository.getChallengeById(challengeId);
}