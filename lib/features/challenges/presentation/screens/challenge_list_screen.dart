import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/challenge_list_content.dart';
import 'create_challenge_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  final int? initialTabIndex;

  const ChallengeListScreen({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const ChallengeListContent(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'challengesFAB',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateChallengeScreen()),
            );
          },
          tooltip: 'Create New Challenge',
          child: Icon(Iconsax.add),
      ),

    );
  }
}