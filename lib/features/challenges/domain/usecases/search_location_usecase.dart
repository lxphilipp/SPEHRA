import '../../../../core/usecases/use_case.dart';
import '../entities/address_entity.dart';
import '../repositories/challenge_repository.dart';

class SearchLocationUseCase implements UseCase<List<AddressEntity>, String> {
  final ChallengeRepository repository;

  SearchLocationUseCase(this.repository);

  @override
  Future<List<AddressEntity>> call(String params) async {
    if (params.isEmpty) return [];
    return await repository.searchLocation(params);
  }
}