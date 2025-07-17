import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/challenge_list_content.dart';
import 'create_challenge_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  final int? initialTabIndex;
  final bool isSelectionMode; // <-- PARAMETER ADDED

  const ChallengeListScreen({
    super.key,
    this.initialTabIndex,
    this.isSelectionMode = false, // <-- Default value is 'false'
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // IMPORTANT: We pass the parameter here
        body: ChallengeListContent(
          initialTabIndex: initialTabIndex,
          isSelectionMode: isSelectionMode, // <-- PASSED HERE
        ),
        floatingActionButton: isSelectionMode ? null : FloatingActionButton( // Hide FAB in selection mode
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