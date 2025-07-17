import '../../../../core/usecases/use_case.dart';
import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';


/// This Use Case fetches the stream of all available challenges.
/// It implements the general UseCase interface for consistency.
class GetAllChallengesStreamUseCase implements UseCase<Stream<List<ChallengeEntity>?>, NoParams> {
  final ChallengeRepository repository;

  GetAllChallengesStreamUseCase(this.repository);

  /// Retrieves the stream of challenges from the repository.
  @override
  Future<Stream<List<ChallengeEntity>?>> call(NoParams params) async {
    return repository.getAllChallengesStream();
  }
}