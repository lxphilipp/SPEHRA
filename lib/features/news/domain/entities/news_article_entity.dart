// lib/features/news/domain/entities/news_article_entity.dart
import 'package:flutter/foundation.dart' show immutable;

@immutable
class NewsArticleEntity {
  final String title;
  final String link;
  final String summary;
  final DateTime? pubDate;
  final String? imageUrl;

  const NewsArticleEntity({
    required this.title,
    required this.link,
    required this.summary,
    this.pubDate,
    this.imageUrl,
  });
}