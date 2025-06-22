import 'package:flutter/material.dart';
// Importiere dein Haupt-Layout, wenn du eines hast, das hier passt
// z.B. import 'package:dein_projekt_name/features/home/presentation/layouts/main_app_layout.dart';
import '../widgets/create_challenge_form.dart'; // Das neue Formular-Widget

class CreateChallengeScreen extends StatelessWidget {
  const CreateChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dein altes CreateOwnChallengesScreen hat HomePageLayout verwendet.
    // return HomePageLayout(
    //   body: CreateChallengeForm(),
    // );

    // Für ein einfaches Scaffold:
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create New Challenge', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: const CreateChallengeForm(),
    );
  }
}