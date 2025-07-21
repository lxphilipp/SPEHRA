import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../../chat/presentation/providers/group_chat_provider.dart';
import '../../domain/entities/group_challenge_progress_entity.dart';

/// A dedicated card to display the status of a group challenge.
class GroupChallengeStatusCard extends StatelessWidget {
  final GroupChallengeProgressEntity groupProgress;

  const GroupChallengeStatusCard({
    super.key,
    required this.groupProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupProvider = context.watch<GroupChatProvider>();

    final double progressPercentage = groupProgress.totalTasksRequired > 0
        ? groupProgress.completedTasksCount / groupProgress.totalTasksRequired
        : 0;

    final bool isCompleted = progressPercentage >= 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      elevation: isCompleted ? 1.0 : 4.0,
      color: isCompleted ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              children: [
                Icon(isCompleted ? Iconsax.award : Iconsax.people, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "TEAM CHALLENGE STATUS",
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              isCompleted
                  ? "Fantastic! You made it as a team!"
                  : "${groupProgress.completedTasksCount} of ${groupProgress.totalTasksRequired} tasks completed.",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercentage,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),

            // --- NEW MILESTONE SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMilestoneWidget(theme, 50, groupProgress.unlockedMilestones.contains(50)),
                _buildMilestoneWidget(theme, 100, groupProgress.unlockedMilestones.contains(100)),
              ],
            ),
            const SizedBox(height: 20),

            Text("Active Participants:", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: -10.0,
              children: groupProgress.participantIds.map((userId) {
                final userDetails = groupProvider.getMemberDetail(userId);
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: userDetails?.imageUrl != null ? NetworkImage(userDetails!.imageUrl!) : null,
                    child: userDetails?.imageUrl == null
                        ? Text(userDetails?.name.substring(0, 1).toUpperCase() ?? "?")
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMilestoneWidget(ThemeData theme, int milestonePercentage, bool isUnlocked) {
    return Column(
      children: [
        Icon(
          isUnlocked ? Iconsax.award5 : Iconsax.award,
          color: isUnlocked ? Colors.amber.shade600 : theme.disabledColor,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          "$milestonePercentage% Bonus",
          style: theme.textTheme.bodySmall?.copyWith(
            color: isUnlocked ? Colors.amber.shade600 : theme.disabledColor,
            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}