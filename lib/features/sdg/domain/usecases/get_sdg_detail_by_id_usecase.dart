import '../entities/sdg_detail_entity.dart';
import '../repositories/sdg_repository.dart';

class GetSdgDetailByIdUseCase {
  final SdgRepository repository;

  GetSdgDetailByIdUseCase(this.repository);

  Future<SdgDetailEntity?> call(String sdgId) async {
    if (sdgId.isEmpty) return null;
    return await repository.getSdgDetailById(sdgId);
  }
}