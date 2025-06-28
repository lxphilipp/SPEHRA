import 'package:flutter/material.dart';
// Importiere dein Haupt-Layout, wenn du eines hast, das hier passt
// z.B. import 'package:dein_projekt_name/features/home/presentation/layouts/responsive_main_navigation.dart';
import '../widgets/challenge_details_content.dart'; // Der Hauptinhalt

class ChallengeDetailsScreen extends StatelessWidget {
  final String challengeId;
  // Optional: Du könntest hier initiale Daten (z.B. Titel) übergeben,
  // um sie anzuzeigen, während die vollen Details geladen werden.
  // final String? initialTitle;

  const ChallengeDetailsScreen({
    super.key,
    required this.challengeId,
    // this.initialTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Wenn du ein generisches Layout wie HomePageLayout verwenden möchtest:
    // return HomePageLayout(
    //   body: ChallengeDetailsContent(challengeId: challengeId, initialTitle: initialTitle),
    // );

    // Für ein einfaches Scaffold:
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Die AppBar wird jetzt Teil des ChallengeDetailsContent oder hier definiert
      appBar: AppBar(
        title: Text(/*initialTitle ??*/ 'Challenge Details', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme, // Für den Back-Button
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: ChallengeDetailsContent(challengeId: challengeId),
    );
  }
}