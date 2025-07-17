import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Core Widgets & Logic
import '../../../../core/theme/sdg_color_theme.dart';
import '../providers/challenge_provider.dart';
import 'task_progress_list_item.dart'; // Our new, interactive widget

// Feature Provider & Entities
import '../../domain/entities/challenge_entity.dart';
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
    // Fetches details and progress when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeProvider>(context, listen: false)
          .fetchChallengeDetails(widget.challengeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.selectedChallenge;
        final theme = Theme.of(context);

        // --- Loading and Error States ---
        if (provider.isLoadingSelectedChallenge && challenge == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.selectedChallengeError != null) {
          return Center(child: Text('Error: ${provider.selectedChallengeError}'));
        }
        if (challenge == null) {
          return const Center(child: Text('No Challenge Details Available.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, challenge, theme),
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
                child: Text('Your Tasks', style: theme.textTheme.titleLarge),
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

  /// Builds the visual header with title and category icon.
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

  /// Builds the row with statistics (points & difficulty).
  Widget _buildStatsRow(BuildContext context, ChallengeEntity challenge, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(theme, Iconsax.star_1, '${challenge.calculatedPoints} Pts', 'Points'),
        _buildStatItem(theme, Iconsax.diagram, challenge.calculatedDifficulty, 'Difficulty'),
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

  /// Builds the SDG category chips.
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

  /// Builds the list of interactive task widgets.
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

  /// Builds the action buttons based on the current state.
  Widget _buildActionButtons(BuildContext context, ChallengeProvider provider) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;
    final challenge = provider.selectedChallenge!;

    final bool isOngoing = userProfile?.ongoingTasks.contains(challenge.id) ?? false;
    final bool isCompleted = userProfile?.completedTasks.contains(challenge.id) ?? false;

    if (isCompleted) {
      return Center(child: Chip(
        avatar: Icon(Icons.check_circle, color: Colors.green),
        label: Text('Completed!'),
      ));
    }

    if (isOngoing) {
      return Column(
        children: [
          // Display error messages, if any
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
              label: Text('Complete Challenge'),
              onPressed: () => provider.completeCurrentChallenge(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => provider.removeCurrentChallengeFromOngoing(),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text('Cancel'),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text('Accept Challenge'),
        onPressed: () => provider.acceptCurrentChallenge(),
      ),
    );
  }
}