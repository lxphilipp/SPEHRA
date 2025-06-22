import 'package:flutter/material.dart';
import '../widgets/sdg_detail_content_widget.dart';

class SdgDetailScreen extends StatelessWidget {
  final String sdgId; // z.B. "goal1", "goal2"
  final String? initialTitle; // Für die AppBar, während die Details geladen werden

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
        iconTheme: theme.appBarTheme.iconTheme, // Stellt sicher, dass der Back-Button die richtige Farbe hat
        elevation: theme.appBarTheme.elevation,
      ),
      body: SdgDetailContentWidget(sdgId: sdgId),
    );
  }
}