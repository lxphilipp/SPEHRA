import '../entities/news_article_entity.dart';

abstract class NewsRepository {
  /// Fetches and parses the news articles from the UN RSS feed.
  /// Returns a list of [NewsArticleEntity] on success, or null on failure.
  Future<List<NewsArticleEntity>?> fetchUnSdgNews();
}