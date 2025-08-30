import 'package:flutter/cupertino.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../domain/usecases/fetch_un_sdg_news_usecase.dart';

class NewsProvider with ChangeNotifier {
  final FetchUnSdgNewsUseCase _fetchNewsUseCase;

  NewsProvider({required FetchUnSdgNewsUseCase fetchNewsUseCase})
      : _fetchNewsUseCase = fetchNewsUseCase {
    fetchNews();
  }

  List<NewsArticleEntity> _articles = [];
  bool _isLoading = false;
  String? _error;

  // --- SORTING STATE ---
  String _sortCriteria = 'pubDate_desc'; // Default: Newest first
  bool get _isSortAscending => _sortCriteria.endsWith('_asc');

  bool get isLoading => _isLoading;
  String? get error => _error;

  // This getter returns the sorted list of articles
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

  // Method to set the sort criteria from the UI
  void setSortCriteria(String newSortValue) {
    if (_sortCriteria != newSortValue) {
      _sortCriteria = newSortValue;
      notifyListeners();
    }
  }

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