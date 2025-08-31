import 'package:intl/intl.dart';

import '../../domain/entities/news_article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

/// Implements the [NewsRepository] interface to provide news articles.
///
/// This repository fetches news from a remote data source and maps the
/// data to [NewsArticleEntity] objects.
class NewsRepositoryImpl implements NewsRepository {
  /// The remote data source for fetching news.
  final NewsRemoteDataSource remoteDataSource;

  /// Creates a [NewsRepositoryImpl].
  ///
  /// Requires a [NewsRemoteDataSource] to fetch news data.
  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NewsArticleEntity>?> fetchUnSdgNews() async {
    final rssFeed = await remoteDataSource.fetchUnSdgRssFeed();

    if (rssFeed == null) {
      return null;
    }

    return rssFeed.items.map((item) {
      String? imageUrl;
      // Attempt to get image URL from enclosure first
      if (item.enclosure != null && item.enclosure!.url != null) {
        imageUrl = item.enclosure!.url;
      }
      // Fallback to media contents if enclosure is not available or has no URL
      else if (item.media?.contents != null &&
          item.media!.contents.isNotEmpty) {
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

  /// Parses a date string into a [DateTime] object.
  ///
  /// Attempts to parse the [dateString] using the RFC 822 format first.
  /// If that fails, it tries a more general [DateTime.parse].
  /// Returns `null` if parsing fails or if the [dateString] is null.
  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // 'E, dd MMM yyyy HH:mm:ss Z' is the pattern for RFC 822 dates.
      // We specify 'en_US' as the locale to ensure "Jul" (and other month abbreviations)
      // are parsed correctly, as the default locale might differ.
      return DateFormat('E, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(dateString);
    } catch (e) {
      // Fallback parsing attempt for other ISO 8601 formats
      try {
        return DateTime.parse(dateString);
      } catch (e2) {
        // Log the error if both parsing attempts fail
        print('Could not parse date: $dateString. Error1: $e, Error2: $e2');
        return null;
      }
    }
  }

  /// Strips HTML tags and HTML entities from a given [text].
  ///
  /// If the [text] is null, returns null. Otherwise, removes all
  /// HTML tags (e.g., `<p>`, `<strong>`) and HTML entities (e.g., `&nbsp;`, `&amp;`)
  /// and trims whitespace from the result.
  String? _stripHtmlIfNeeded(String? text) {
    if (text == null) return null;
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }
}
