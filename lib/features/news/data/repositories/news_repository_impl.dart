// lib/features/news/data/repositories/news_repository_impl.dart
import 'package:intl/intl.dart';

import '../../domain/entities/news_article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NewsArticleEntity>?> fetchUnSdgNews() async {
    final rssFeed = await remoteDataSource.fetchUnSdgRssFeed();

    if (rssFeed == null) {
      return null;
    }

    return rssFeed.items.map((item) {
      // --- CORRECTED LOGIC ---
      // Prioritize the enclosure tag for the image URL as you correctly pointed out.
      String? imageUrl;
      if (item.enclosure != null && item.enclosure!.url != null) {
        imageUrl = item.enclosure!.url;
      }
      // As a fallback, we can still check for media:content, just in case
      // the feed format changes or contains mixed item types.
      else if (item.media?.contents != null && item.media!.contents.isNotEmpty) {
        imageUrl = item.media!.contents.first.url;
      }

      return NewsArticleEntity(
        title: item.title ?? 'No Title',
        link: item.link ?? '',
        summary: _stripHtmlIfNeeded(item.description) ?? 'No Summary',
        pubDate: _parseDate(item.pubDate),
        imageUrl: imageUrl,
      );
    }).toList();
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // 'E, dd MMM yyyy HH:mm:ss Z' is the pattern for RFC 822 dates.
      // We specify 'en_US' as the locale to ensure "Jul" is parsed correctly.
      return DateFormat('E, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(dateString);
    } catch (e) {
      // As a fallback, try the default parser, though it's unlikely to succeed here.
      try {
        return DateTime.parse(dateString);
      } catch (e2) {
        print('Could not parse date: $dateString');
        return null;
      }
    }
  }

  String? _stripHtmlIfNeeded(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }
}