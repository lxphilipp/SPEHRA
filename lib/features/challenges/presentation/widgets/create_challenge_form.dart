import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider und Entitäten
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/challenge_provider.dart';

// Die einzelnen Seiten unseres Baukastens
import 'creation_steps/step_1_title_page.dart';
import 'creation_steps/step_2_description_page.dart';
import 'creation_steps/step_3_categories_page.dart';
import 'creation_steps/step_4_tasks_page.dart';
import 'creation_steps/step_5_preview_page.dart';

/// Dieses Widget ist der "Baukasten" oder "Wizard" für die Challenge-Erstellung.
/// Es verwendet eine PageView, um den Nutzer durch die einzelnen Schritte zu führen.
class CreateChallengeForm extends StatefulWidget {
  const CreateChallengeForm({super.key});

  @override
  State<CreateChallengeForm> createState() => _CreateChallengeFormState();
}

class _CreateChallengeFormState extends State<CreateChallengeForm> {
  final List<Widget> _pages = [
    const Step1TitlePage(),
    const Step2DescriptionPage(),
    const Step3CategoriesPage(),
    const Step4TasksPage(),
    const Step5PreviewPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authorId = context.read<AuthenticationProvider>().currentUserId;
      if (authorId != null) {
        context.read<ChallengeProvider>().startChallengeCreation(authorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final theme = Theme.of(context);

    // Zeige einen Ladekreis, bis der Baukasten initialisiert ist
    if (provider.challengeInProgress == null || provider.pageController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLastPage = provider.currentPage == _pages.length - 1;

    return Column(
      children: [
        // 1. Eine Fortschrittsanzeige, die den aktuellen Schritt visualisiert
        LinearProgressIndicator(
          value: (provider.currentPage + 1) / _pages.length,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),

        // 2. Die PageView, die den Großteil des Screens einnimmt
        Expanded(
          child: PageView.builder(
            controller: provider.pageController,
            physics: const NeverScrollableScrollPhysics(), // Swipen deaktivieren
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
        ),

        // 3. Eine feste Navigationsleiste am unteren Rand
        _buildBottomNavigationBar(context, provider, isLastPage),
      ],
    );
  }

  /// Baut die Navigationsleiste am unteren Rand des Screens.
  Widget _buildBottomNavigationBar(BuildContext context, ChallengeProvider provider, bool isLastPage) {
    // Validierung für den "Weiter" oder "Veröffentlichen" Button
    bool canProceed = false;
    final challenge = provider.challengeInProgress;
    if (challenge != null) {
      switch (provider.currentPage) {
        case 0: // Titel
          canProceed = challenge.title.isNotEmpty;
          break;
        case 1: // Beschreibung
          canProceed = challenge.description.isNotEmpty;
          break;
        case 2: // Kategorien
          canProceed = challenge.categories.isNotEmpty;
          break;
        case 3: // Aufgaben
          canProceed = challenge.tasks.isNotEmpty;
          break;
        case 4: // Vorschau
          canProceed = true; // Auf der Vorschauseite kann man immer veröffentlichen
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "Zurück"-Button (nur sichtbar ab der zweiten Seite)
          if (provider.currentPage > 0)
            TextButton(
              onPressed: () => provider.previousPage(),
              child: const Text('Zurück'),
            )
          else
            const SizedBox(), // Leerer Platzhalter, damit der "Weiter"-Button rechts bleibt

          // Der finale Button: "Weiter" oder "Veröffentlichen"
          ElevatedButton.icon(
            icon: provider.isCreatingChallenge
                ? Container()
                : Icon(isLastPage ? Iconsax.send_1 : Icons.arrow_forward_ios_rounded, size: 18),
            label: provider.isCreatingChallenge
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isLastPage ? 'Veröffentlichen' : 'Weiter'),
            onPressed: canProceed && !provider.isCreatingChallenge
                ? () async {
              if (isLastPage) {
                final newId = await provider.saveChallenge();
                if (!context.mounted) return;

                if (newId != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge erfolgreich erstellt!')),
                  );
                  Navigator.of(context).pop();
                }
              } else {
                provider.nextPage();
              }
            }
                : null,
          ),
        ],
      ),
    );
  }
}