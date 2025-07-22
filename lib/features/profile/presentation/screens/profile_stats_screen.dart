import 'package:flutter/material.dart';
import '../widgets/profile_stats_content.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: ProfileStatsContent(),
    );
  }
}