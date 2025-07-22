// lib/features/news/presentation/providers/news_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../domain/usecases/fetch_un_sdg_news_usecase.dart';

class NewsProvider with ChangeNotifier {
  final FetchUnSdgNewsUseCase _fetchNewsUseCase;

  NewsProvider({required FetchUnSdgNewsUseCase fetchNewsUseCase})
      : _fetchNewsUseCase = fetchNewsUseCase {
    fetchNews();
  }

  List<NewsArticleEntity> _articles = [];
  List<NewsArticleEntity> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

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