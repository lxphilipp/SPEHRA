import 'package:flutter/material.dart';
// Import your main layout if you have one that fits here
// e.g. import 'package:your_project_name/features/home/presentation/layouts/responsive_main_navigation.dart';
import '../widgets/challenge_details_content.dart'; // The main content

class ChallengeDetailsScreen extends StatelessWidget {
  final String challengeId;

  const ChallengeDetailsScreen({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text( 'Challenge Details', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme, // For the back button
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: ChallengeDetailsContent(challengeId: challengeId),
    );
  }
}