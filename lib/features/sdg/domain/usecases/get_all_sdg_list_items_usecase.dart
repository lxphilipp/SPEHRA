import '../entities/sdg_list_item_entity.dart';
import '../repositories/sdg_repository.dart';

class GetAllSdgListItemsUseCase {
  final SdgRepository repository;

  GetAllSdgListItemsUseCase(this.repository);

  Future<List<SdgListItemEntity>?> call() async {
    return await repository.getAllSdgListItems();
  }
}