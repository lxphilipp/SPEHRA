import '../../../../core/usecases/use_case.dart';
import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';

/// Dieser Use Case holt die Details einer einzelnen Challenge anhand ihrer ID.
class GetChallengeByIdUseCase implements UseCase<ChallengeEntity?, String> {
  final ChallengeRepository repository;

  GetChallengeByIdUseCase(this.repository);

  /// Ruft eine Challenge anhand ihrer ID ab.
  /// [params] ist hier direkt die challengeId als String.
  @override
  Future<ChallengeEntity?> call(String params) async {
    return await repository.getChallengeById(params);
  }
}