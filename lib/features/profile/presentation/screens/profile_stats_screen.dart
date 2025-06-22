import 'package:flutter/material.dart';
// Importiere dein Layout, wenn es verwendet wird
import '../../../../core/layouts/main_app_layout.dart'; // Beispiel
import '../widgets/profile_stats_content.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dein altes ProfileScreen hat HomePageLayout verwendet.
    // Wenn das immer noch passt:
    return const MainAppLayout( // Oder ein anderes passendes Layout
      body: ProfileStatsContent(),
    );
    // Oder ein einfaches Scaffold, wenn kein spezielles Layout nötig:
    /*
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Stats', style: Theme.of(context).appBarTheme.titleTextStyle),
        // ...
      ),
      body: const ProfileStatsContent(),
    );
    */
  }
}