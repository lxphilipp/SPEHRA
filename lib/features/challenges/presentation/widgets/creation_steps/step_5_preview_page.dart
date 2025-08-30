import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../sdg/domain/entities/sdg_list_item_entity.dart';
import '../../../../sdg/presentation/providers/sdg_list_provider.dart';
import '../../../presentation/providers/challenge_provider.dart';

class Step5PreviewPage extends StatelessWidget {
  const Step5PreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final challenge = provider.challengeInProgress;
    final theme = Theme.of(context);
    final balance = provider.gameBalance;
    final sdgListProvider = context.watch<SdgListProvider>();

    if (challenge == null) {
      return const Center(child: Text('Error: No challenge in progress.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Almost done! Here is the preview',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Review everything and publish your challenge to inspire others.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // --- Summary Card ---
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(challenge.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Description
                  Text(challenge.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),

                  // Categories
                  if (challenge.categories.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: challenge.categories.map((catKey) {
                        final sdgItem = sdgListProvider.sdgListItems.firstWhere(
                              (item) => item.id == catKey,
                          orElse: () => SdgListItemEntity(id: catKey, title: catKey, listImageAssetPath: ''),
                        );
                        return Chip(
                          label: Text(sdgItem.title, style: theme.textTheme.labelSmall),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      }).toList(),
                    ),
                  const Divider(height: 32),

                  // Calculated values
                  _buildStatRow(
                    context,
                    icon: Iconsax.star_1,
                    label: 'Points',
                    value: '${challenge.calculatePoints(balance!)} Pts',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    icon: Iconsax.diagram,
                    label: 'Difficulty',
                    value: challenge.calculateDifficulty(balance),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // List of tasks
          Text('Tasks (${challenge.tasks.length})', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var task in challenge.tasks)
            ListTile(
              dense: true,
              leading: const Icon(Iconsax.arrow_right_3, size: 16),
              title: Text(task.description, style: theme.textTheme.bodyMedium),
            ),

        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text('$label:', style: theme.textTheme.bodyLarge),
        const Spacer(),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}