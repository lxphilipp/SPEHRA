import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Core Widgets & Logik
import '../../../../core/theme/sdg_color_theme.dart';
import 'task_progress_list_item.dart'; // Unser neues, interaktives Widget

// Feature Provider & Entities
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class ChallengeDetailsContent extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailsContent({
    super.key,
    required this.challengeId,
  });

  @override
  State<ChallengeDetailsContent> createState() => _ChallengeDetailsContentState();
}

class _ChallengeDetailsContentState extends State<ChallengeDetailsContent> {
  @override
  void initState() {
    super.initState();
    // Ruft die Details und den Fortschritt ab, wenn das Widget zum ersten Mal gebaut wird.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeProvider>(context, listen: false)
          .fetchChallengeDetails(widget.challengeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wir verwenden `Consumer` hier, um gezielt auf Änderungen zu lauschen.
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.selectedChallenge;
        final theme = Theme.of(context);

        // --- Lade- und Fehlerzustände ---
        if (provider.isLoadingSelectedChallenge && challenge == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.selectedChallengeError != null) {
          return Center(child: Text('Fehler: ${provider.selectedChallengeError}'));
        }
        if (challenge == null) {
          return const Center(child: Text('Keine Challenge-Details verfügbar.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header-Sektion ---
              _buildHeader(context, challenge, theme),

              // --- 2. Hauptinhalt (Beschreibung, Statistiken) ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.description, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    _buildStatsRow(context, challenge, theme),
                    const SizedBox(height: 16),
                    if (challenge.categories.isNotEmpty)
                      _buildSdgChips(context, challenge, theme),
                  ],
                ),
              ),

              // --- 3. Interaktive Aufgabenliste ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Deine Aufgaben', style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 8),
              _buildTaskList(context, provider, challenge),

              // --- 4. Aktions-Buttons ---
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildActionButtons(context, provider),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  /// Baut den visuellen Header mit Titel und Kategorie-Icon.
  Widget _buildHeader(BuildContext context, ChallengeEntity challenge, ThemeData theme) {
    final sdgTheme = theme.extension<SdgColorTheme>();
    String imagePath = 'assets/icons/17_SDG_Icons/1.png'; // Fallback
    if (challenge.categories.isNotEmpty) {
      final categoryIndex = int.tryParse(challenge.categories.first.replaceAll('goal', '')) ?? 1;
      imagePath = 'assets/icons/17_SDG_Icons/$categoryIndex.png';
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      color: sdgTheme?.colorForSdgKey(challenge.categories.firstOrNull ?? '').withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          const SizedBox(height: 12),
          Text(
            challenge.title,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Baut die Reihe mit den Statistiken (Punkte & Schwierigkeit).
  Widget _buildStatsRow(BuildContext context, ChallengeEntity challenge, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(theme, Iconsax.star_1, '${challenge.calculatedPoints} Pts', 'Punkte'),
        _buildStatItem(theme, Iconsax.diagram, challenge.calculatedDifficulty, 'Schwierigkeit'),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  /// Baut die SDG-Kategorie-Chips.
  Widget _buildSdgChips(BuildContext context, ChallengeEntity challenge, ThemeData theme) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: challenge.categories.map((catKey) {
        return Chip(
          label: Text(catKey, style: theme.textTheme.labelSmall),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        );
      }).toList(),
    );
  }

  /// Baut die Liste der interaktiven Aufgaben-Widgets.
  Widget _buildTaskList(BuildContext context, ChallengeProvider provider, ChallengeEntity challenge) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: challenge.tasks.length,
      itemBuilder: (context, index) {
        final taskDefinition = challenge.tasks[index];
        final taskProgress = provider.currentChallengeProgress?.taskStates[index.toString()];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TaskProgressListItem(
            taskDefinition: taskDefinition,
            taskProgress: taskProgress,
            taskIndex: index,
          ),
        );
      },
    );
  }

  /// Baut die Aktionsbuttons basierend auf dem aktuellen Zustand.
  Widget _buildActionButtons(BuildContext context, ChallengeProvider provider) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;
    final challenge = provider.selectedChallenge!;

    final bool isOngoing = userProfile?.ongoingTasks.contains(challenge.id) ?? false;
    final bool isCompleted = userProfile?.completedTasks.contains(challenge.id) ?? false;

    if (isCompleted) {
      return Center(child: Chip(
        avatar: Icon(Icons.check_circle, color: Colors.green),
        label: Text('Abgeschlossen!'),
      ));
    }

    if (isOngoing) {
      return Column(
        children: [
          // Fehlermeldungen anzeigen, falls vorhanden
          if (provider.userChallengeStatusError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                provider.userChallengeStatusError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: Icon(Iconsax.send_1),
              label: Text('Challenge abschließen'),
              onPressed: () => provider.completeCurrentChallenge(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              child: Text('Abbrechen'),
              onPressed: () => provider.removeCurrentChallengeFromOngoing(),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      );
    }

    // Wenn noch nicht angenommen
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text('Challenge annehmen'),
        onPressed: () => provider.acceptCurrentChallenge(),
      ),
    );
  }
}