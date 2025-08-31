import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Core Widgets & Logic
import '../../../../core/theme/sdg_color_theme.dart';
import '../../domain/entities/game_balance_entity.dart';
import '../providers/challenge_provider.dart';
import 'task_progress_list_item.dart';

// Feature Provider & Entities
import '../../domain/entities/challenge_entity.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../sdg/domain/entities/sdg_list_item_entity.dart';
import '../../../sdg/presentation/providers/sdg_list_provider.dart';

/// A widget that displays the detailed content of a specific challenge.
///
/// It fetches and shows information suchs as the challenge title, description,
/// SDG categories, points, difficulty, tasks, and action buttons
/// (e.g., accept, complete, cancel challenge).
class ChallengeDetailsContent extends StatefulWidget {
  /// The unique identifier of the challenge to display.
  final String challengeId;

  /// Creates a [ChallengeDetailsContent] widget.
  ///
  /// Requires a [challengeId] to fetch and display the relevant challenge details.
  const ChallengeDetailsContent({
    super.key,
    required this.challengeId,
  });

  @override
  State<ChallengeDetailsContent> createState() => _ChallengeDetailsContentState();
}

/// The state class for the [ChallengeDetailsContent] widget.
///
/// Handles the lifecycle and UI building for displaying challenge details.
/// It uses a [ChallengeProvider] to fetch and manage challenge data.
class _ChallengeDetailsContentState extends State<ChallengeDetailsContent> {
  /// Initializes the state.
  ///
  /// Fetches the challenge details after the first frame is rendered.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeProvider>(context, listen: false)
          .fetchChallengeDetails(widget.challengeId);
    });
  }

  /// Builds the widget tree for displaying challenge details.
  ///
  /// It consumes [ChallengeProvider] to get the challenge data and
  /// displays loading, error, or content based on the provider's state.
  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final challenge = provider.selectedChallenge;
        final theme = Theme.of(context);
        final balance = provider.gameBalance;

        if (provider.isLoadingSelectedChallenge || balance == null) {
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
                    _buildStatsRow(context, challenge, theme, balance),
                    const SizedBox(height: 24),

                    Text("Description", style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(challenge.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 24),

                    if (challenge.categories.isNotEmpty) ...[
                      Text("Categories", style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildSdgChips(context, challenge, theme),
                    ]
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Your Tasks', style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 8),
              _buildTaskList(context, provider, challenge),
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

  // --- WIDGET BUILDER METHODS ---

  /// Builds the header section of the challenge details page.
  ///
  /// Displays the SDG icon and title of the challenge.
  /// The background color is determined by the first SDG category of the challenge.
  Widget _buildHeader(BuildContext context, ChallengeEntity challenge, ThemeData theme) {
    final sdgTheme = theme.extension<SdgColorTheme>();
    final sdgListProvider = context.read<SdgListProvider>();

    String imagePath = 'assets/icons/17_SDG_Icons/1.png'; // Fallback
    final firstCategoryKey = challenge.categories.firstOrNull;

    if (firstCategoryKey != null) {
      final sdgItem = sdgListProvider.sdgListItems.firstWhere(
            (item) => item.id == firstCategoryKey,
        orElse: () => SdgListItemEntity(id: firstCategoryKey, title: firstCategoryKey, listImageAssetPath: imagePath),
      );
      imagePath = sdgItem.listImageAssetPath;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      color: sdgTheme?.colorForSdgKey(firstCategoryKey ?? '').withOpacity(0.1),
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

  /// Builds a section displaying SDG category chips for the challenge.
  ///
  /// Each chip represents an SDG category associated with the challenge
  /// and includes an icon and label.
  Widget _buildSdgChips(BuildContext context, ChallengeEntity challenge, ThemeData theme) {
    final sdgListProvider = context.read<SdgListProvider>();

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: challenge.categories.map((catKey) {
        final sdgItem = sdgListProvider.sdgListItems.firstWhere(
              (item) => item.id == catKey,
          orElse: () => SdgListItemEntity(id: catKey, title: catKey, listImageAssetPath: ''),
        );

        final labelText = sdgItem.title;
        final iconPath = sdgItem.listImageAssetPath;

        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset(iconPath,
              errorBuilder: (context, error, stackTrace) => const Icon(Iconsax.global, size: 18),
            ),
          ),
          label: Text(labelText, style: theme.textTheme.labelSmall),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        );
      }).toList(),
    );
  }

  /// Builds a row displaying statistics about the challenge, such as points and difficulty.
  ///
  /// Returns an empty SizedBox if game balance is not available.
  Widget _buildStatsRow(BuildContext context, ChallengeEntity challenge, ThemeData theme, GameBalanceEntity? balance) {
    if (balance == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(theme, Iconsax.star_1, '${challenge.calculatePoints(balance)} Pts', 'Points'),
        _buildStatItem(theme, Iconsax.diagram, challenge.calculateDifficulty(balance), 'Difficulty'),
      ],
    );
  }

  /// Builds a single statistic item with an icon, value, and label.
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

  /// Builds the list of tasks for the current challenge.
  ///
  /// Each task is represented by a [TaskProgressListItem].
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

  /// Builds the action buttons for the challenge based on its current state
  /// (e.g., completed, ongoing, or available to accept).
  ///
  /// - If completed, shows a "Completed!" chip.
  /// - If ongoing, shows "Complete Challenge" and "Cancel" buttons.
  /// - Otherwise, shows an "Accept Challenge" button.
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
