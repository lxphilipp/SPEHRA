import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/feature_screen_header.dart';
import '../../domain/entities/news_article_entity.dart';
import '../provider/news_provider.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Use the consistent header widget
            FeatureScreenHeader(
              title: "News",
              actions: [
                // Use PopupMenuButton exactly like in the Chat screen
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.sort),
                  tooltip: "Sort by...",
                  onSelected: (String value) {
                    provider.setSortCriteria(value);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'pubDate_desc', // Value for newest first
                      child: Text('Newest first'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'pubDate_asc', // Value for oldest first
                      child: Text('Oldest first'),
                    ),
                  ],
                ),
              ],
            ),
            // 2. The main content (remains unchanged)
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(provider.error!),
                      ),
                    );
                  }

                  final articles = provider.articles;
                  if (articles.isEmpty) {
                    return const Center(child: Text('No news articles found.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.fetchNews(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return _NewsListItem(article: articles[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _NewsListItem Widget remains unchanged
class _NewsListItem extends StatelessWidget {
  final NewsArticleEntity article;

  const _NewsListItem({required this.article});

  Future<void> _launchArticleUrl() async {
    final uri = Uri.tryParse(article.link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _launchArticleUrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Image.network(
                article.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                headers: const {
                  'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36',
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 48,
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (article.pubDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${article.pubDate!.day}.${article.pubDate!.month}.${article.pubDate!.year}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}