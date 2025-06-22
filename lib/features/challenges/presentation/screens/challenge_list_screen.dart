import 'package:flutter/material.dart';
// Importiere dein Haupt-Layout, wenn du eines hast, das hier passt
// z.B. import 'package:dein_projekt_name/features/home/presentation/layouts/main_app_layout.dart';
import '../widgets/challenge_list_content.dart'; // Der Hauptinhalt

class ChallengeListScreen extends StatelessWidget {
  final int? initialTabIndex; // Um einen bestimmten Tab vorzuselektieren

  const ChallengeListScreen({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    // Wenn du ein generisches Layout wie HomePageLayout verwenden möchtest:
    // return HomePageLayout(
    //   body: ChallengeListContent(initialTabIndex: initialTabIndex),
    // );

    // Für ein einfaches Scaffold, wenn kein spezielles Layout benötigt wird
    // oder das Layout im ChallengeListContent selbst gehandhabt wird (z.B. mit CustomScrollView)
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Die AppBar wird jetzt Teil des ChallengeListContent (mit CustomScrollView)
      // oder könnte hier definiert werden, wenn ChallengeListContent kein CustomScrollView verwendet.
      body: ChallengeListContent(initialTabIndex: initialTabIndex),
    );
  }
}