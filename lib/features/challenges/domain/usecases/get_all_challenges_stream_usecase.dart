import '../../../../core/usecases/use_case.dart';
import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';


/// Dieser Use Case holt den Stream aller verfügbaren Challenges.
/// Er implementiert das allgemeine UseCase-Interface für Konsistenz.
class GetAllChallengesStreamUseCase implements UseCase<Stream<List<ChallengeEntity>?>, NoParams> {
  final ChallengeRepository repository;

  GetAllChallengesStreamUseCase(this.repository);

  /// Ruft den Stream der Challenges vom Repository ab.
  @override
  Future<Stream<List<ChallengeEntity>?>> call(NoParams params) async {
    return repository.getAllChallengesStream();
  }
}