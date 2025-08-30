import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/challenge_list_content.dart';
import 'create_challenge_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  final int? initialTabIndex;
  final bool isSelectionMode;

  const ChallengeListScreen({
    super.key,
    this.initialTabIndex,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSelectionMode
          ? AppBar(
        title: const Text('Select a Challenge'),
      )
          : null,
      body: SafeArea(
        child: ChallengeListContent(
          initialTabIndex: initialTabIndex,
          isSelectionMode: isSelectionMode,
        ),
      ),
      floatingActionButton: isSelectionMode
          ? null // Hide FAB in selection mode
          : FloatingActionButton(
        heroTag: 'challengesFAB',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateChallengeScreen()),
          );
        },
        tooltip: 'Create New Challenge',
        child: const Icon(Iconsax.add),
      ),
    );
  }
}