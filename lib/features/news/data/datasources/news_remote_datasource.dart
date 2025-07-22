import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import '../../../../core/utils/app_logger.dart';

abstract class NewsRemoteDataSource {
  Future<RssFeed?> fetchUnSdgRssFeed(); // Return type is from the new package
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client _client;
  final String _rssUrl = 'https://news.un.org/feed/subscribe/en/news/topic/sdgs/feed/rss.xml';

  NewsRemoteDataSourceImpl({required http.Client client}) : _client = client;

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