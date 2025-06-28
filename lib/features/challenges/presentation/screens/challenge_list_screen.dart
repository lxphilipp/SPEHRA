import 'package:flutter/material.dart';
// Importiere dein Haupt-Layout, wenn du eines hast, das hier passt
// z.B. import 'package:dein_projekt_name/features/home/presentation/layouts/responsive_main_navigation.dart';
import '../../../../core/widgets/custom_main_app_bar.dart';
import '../../../home/presentation/widgets/home_content.dart';
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