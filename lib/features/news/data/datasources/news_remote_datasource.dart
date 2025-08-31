import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import '../../../../core/utils/app_logger.dart';

/// Abstract interface for fetching news data from a remote source.
abstract class NewsRemoteDataSource {
  /// Fetches the UN SDG RSS feed.
  ///
  /// Returns a [RssFeed] object if successful, otherwise returns `null`.
  Future<RssFeed?> fetchUnSdgRssFeed();
}

/// Implementation of [NewsRemoteDataSource] that fetches news from the UN SDG RSS feed.
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  /// The HTTP client used to make requests.
  final http.Client _client;

  /// The URL of the UN SDG RSS feed.
  final String _rssUrl = 'https://news.un.org/feed/subscribe/en/news/topic/sdgs/feed/rss.xml';

  /// Creates a [NewsRemoteDataSourceImpl] instance.
  ///
  /// Requires an [http.Client] to be provided.
  NewsRemoteDataSourceImpl({required http.Client client}) : _client = client;

  /// Fetches the UN SDG RSS feed.
  ///
  /// Makes an HTTP GET request to the [_rssUrl].
  /// If the request is successful (status code 200), it parses the response body
  /// into an [RssFeed] object and returns it.
  /// If the request fails or an exception occurs, an error is logged using [AppLogger]
  /// and `null` is returned.
  @override
  Future<RssFeed?> fetchUnSdgRssFeed() async {
    try {
      final response = await _client.get(Uri.parse(_rssUrl));
      if (response.statusCode == 200) {
        return RssFeed.parse(response.body);
      } else {
        AppLogger.error("Failed to load RSS feed. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      AppLogger.error("Exception while fetching RSS feed: $e", e);
      return null;
    }
  }
}
