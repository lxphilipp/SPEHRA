import 'package:flutter/cupertino.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../domain/usecases/fetch_un_sdg_news_usecase.dart';

/// Provides and manages news data for the UI.
///
/// This class fetches news articles, handles loading and error states,
/// and provides sorting functionality for the displayed articles.
class NewsProvider with ChangeNotifier {
  final FetchUnSdgNewsUseCase _fetchNewsUseCase;

  /// Creates a [NewsProvider].
  ///
  /// Requires a [FetchUnSdgNewsUseCase] to fetch news articles.
  /// Automatically fetches news when initialized.
  NewsProvider({required FetchUnSdgNewsUseCase fetchNewsUseCase})
      : _fetchNewsUseCase = fetchNewsUseCase {
    fetchNews();
  }

  List<NewsArticleEntity> _articles = [];
  bool _isLoading = false;
  String? _error;

  // --- SORTING STATE ---
  /// The current criteria for sorting articles.
  /// Defaults to 'pubDate_desc' (newest first).
  String _sortCriteria = 'pubDate_desc'; // Default: Newest first

  /// Whether the current sort order is ascending.
  bool get _isSortAscending => _sortCriteria.endsWith('_asc');

  /// Whether news articles are currently being loaded.
  bool get isLoading => _isLoading;

  /// An error message if fetching news failed, otherwise null.
  String? get error => _error;

  /// Returns the list of news articles, sorted according to [_sortCriteria].
  ///
  /// Articles are sorted by their publication date.
  /// If `pubDate` is null, it defaults to DateTime(1970).
  List<NewsArticleEntity> get articles {
    List<NewsArticleEntity> sortedArticles = List.from(_articles);
    sortedArticles.sort((a, b) {
      final aDate = a.pubDate ?? DateTime(1970);
      final bDate = b.pubDate ?? DateTime(1970);
      // Compare dates
      int comparison = aDate.compareTo(bDate);
      // Reverse if descending
      return _isSortAscending ? comparison : -comparison;
    });
    return sortedArticles;
  }

  /// Sets the sort criteria for the news articles.
  ///
  /// If the [newSortValue] is different from the current [_sortCriteria],
  /// it updates the criteria and notifies listeners to rebuild the UI.
  void setSortCriteria(String newSortValue) {
    if (_sortCriteria != newSortValue) {
      _sortCriteria = newSortValue;
      notifyListeners();
    }
  }

  /// Fetches news articles from the repository.
  ///
  /// Sets [isLoading] to true while fetching and updates [_articles]
  /// with the result, or sets [_error] if fetching fails.
  /// Notifies listeners after the operation is complete.
  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _fetchNewsUseCase();

    if (result != null) {
      _articles = result;
    } else {
      _error = "Could not load the news feed.";
      _articles = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}