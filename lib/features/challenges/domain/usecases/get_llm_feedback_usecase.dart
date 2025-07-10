import 'package:equatable/equatable.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/challenge_repository.dart';
import '../entities/challenge_entity.dart';

class GetLlmFeedbackUseCase implements UseCase<String?, GetLlmFeedbackParams> {
  final ChallengeRepository repository;

  GetLlmFeedbackUseCase(this.repository);

  @override
  Future<String?> call(GetLlmFeedbackParams params) async {
    // Der Use Case leitet die Anfrage an das Repository weiter.
    return await repository.getLlmFeedback(
      step: params.step,
      challengeData: params.challengeData,
    );
  }
}

class GetLlmFeedbackParams extends Equatable {
  final String step;
  final ChallengeEntity challengeData;

  const GetLlmFeedbackParams({required this.step, required this.challengeData});

  @override
  List<Object?> get props => [step, challengeData];
}