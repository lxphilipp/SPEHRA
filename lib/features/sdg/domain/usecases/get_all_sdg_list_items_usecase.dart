import '../entities/sdg_list_item_entity.dart';
import '../repositories/sdg_repository.dart';

class GetAllSdgListItemsUseCase {
  final SdgRepository repository;

  GetAllSdgListItemsUseCase(this.repository);

  Future<List<SdgListItemEntity>?> call() async {
    // Hier könnte Logik stehen, z.B. Sortierung der Liste,
    // bevor sie an den Provider geht, falls das nicht im Repo passiert.
    return await repository.getAllSdgListItems();
  }
}