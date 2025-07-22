import '../entities/news_article_entity.dart';
import '../repositories/news_repository.dart';

class FetchUnSdgNewsUseCase{
  final NewsRepository repository;

  FetchUnSdgNewsUseCase(this.repository);

  Future<List<NewsArticleEntity>?> call() async {
    return await repository.fetchUnSdgNews();
  }
}