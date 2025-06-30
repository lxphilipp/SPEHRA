// lib/features/news/presentation/screens/news_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_main_app_bar.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomMainAppBar(
        title: 'News',
      ),
      body: Center(
        child: Text(
          'Hier werden bald die News angezeigt!',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}