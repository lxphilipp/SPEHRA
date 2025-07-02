import 'package:flutter/material.dart';
// Importiere dein Haupt-Layout, wenn du eines hast, das hier passt
// z.B. import 'package:dein_projekt_name/features/home/presentation/layouts/responsive_main_navigation.dart';
import '../widgets/challenge_details_content.dart'; // Der Hauptinhalt

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
        iconTheme: Theme.of(context).appBarTheme.iconTheme, // Für den Back-Button
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: ChallengeDetailsContent(challengeId: challengeId),
    );
  }
}