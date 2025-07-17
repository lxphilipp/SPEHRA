import '../../../../core/usecases/use_case.dart';
import '../entities/challenge_entity.dart';
import '../repositories/challenge_repository.dart';

/// This Use Case fetches the details of a single challenge by its ID.
class GetChallengeByIdUseCase implements UseCase<ChallengeEntity?, String> {
  final ChallengeRepository repository;

  GetChallengeByIdUseCase(this.repository);

  /// Retrieves a challenge by its ID.
  /// [params] here is directly the challengeId as a String.
  @override
  Future<ChallengeEntity?> call(String params) async {
    return await repository.getChallengeById(params);
  }
}