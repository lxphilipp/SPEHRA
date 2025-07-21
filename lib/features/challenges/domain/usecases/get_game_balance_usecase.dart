import '../../../../core/usecases/use_case.dart';
import '../entities/game_balance_entity.dart';
import '../repositories/configuration_repository.dart';

class GetGameBalanceUseCase implements UseCase<GameBalanceEntity, NoParams> {
  final ConfigurationRepository repository;

  GetGameBalanceUseCase(this.repository);

  @override
  Future<GameBalanceEntity> call(NoParams params) {
    return repository.getGameBalance();
  }
}