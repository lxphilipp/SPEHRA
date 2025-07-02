import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_main_app_bar.dart';
import '../widgets/challenge_list_content.dart'; // Der Hauptinhalt

class ChallengeListScreen extends StatelessWidget {
  final int? initialTabIndex; // Um einen bestimmten Tab vorzuselektieren

  const ChallengeListScreen({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: CustomMainAppBar(),
        body: ChallengeListContent()
    );
  }
}