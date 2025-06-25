import '../entities/intro_page_entity.dart';
import '../repositories/intro_repository.dart';

class GetIntroPagesUseCase {
  final IntroRepository repository;
  GetIntroPagesUseCase(this.repository);

  Future<List<IntroPageEntity>> call() {
    return repository.getIntroPages();
  }
}