import 'package:flutter/material.dart';
// Importiere dein Layout, wenn es verwendet wird
// Beispiel
import '../../../../core/widgets/custom_main_app_bar.dart';
import '../widgets/profile_stats_content.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: CustomMainAppBar(),
        body: ProfileStatsContent(),
    );
  }
}