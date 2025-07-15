import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/challenge_list_content.dart';
import 'create_challenge_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  final int? initialTabIndex;
  final bool isSelectionMode; // <-- PARAMETER HINZUGEFÜGT

  const ChallengeListScreen({
    super.key,
    this.initialTabIndex,
    this.isSelectionMode = false, // <-- Standardwert ist 'false'
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // WICHTIG: Wir geben den Parameter hier weiter
        body: ChallengeListContent(
          initialTabIndex: initialTabIndex,
          isSelectionMode: isSelectionMode, // <-- HIER WIRD ER WEITERGEGEBEN
        ),
        floatingActionButton: isSelectionMode ? null : FloatingActionButton( // FAB im Auswahlmodus ausblenden
          heroTag: 'challengesFAB',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateChallengeScreen()),
            );
          },
          tooltip: 'Create New Challenge',
          child: const Icon(Iconsax.add),
        ),
      ),
    );
  }
}