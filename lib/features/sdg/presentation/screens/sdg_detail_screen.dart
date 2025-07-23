import 'package:flutter/material.dart';
import '../widgets/sdg_detail_content_widget.dart';

class SdgDetailScreen extends StatelessWidget {
  final String sdgId;
  final String? initialTitle;

  const SdgDetailScreen({
    super.key,
    required this.sdgId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(initialTitle ?? 'SDG Detail', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: theme.appBarTheme.elevation,
      ),
      body: SdgDetailContentWidget(sdgId: sdgId),
    );
  }
}