// lib/features/challenges/presentation/widgets/challenge_card_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '/core/theme/sdg_color_theme.dart';
import '../../domain/entities/challenge_entity.dart';
// NOTE: We are removing the direct import to ChallengeDetailsScreen
// import '../screens/challenge_details_screen.dart';

class ChallengeCardWidget extends StatelessWidget {
  final ChallengeEntity challenge;
  final VoidCallback onTap; // <-- 1. PARAMETER ADDED

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
    required this.onTap, // <-- 2. ADDED IN CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sdgTheme = theme.extension<SdgColorTheme>();
    final challengeProvider = context.watch<ChallengeProvider>();
    final balance = challengeProvider.gameBalance;

    Color circleColor = theme.colorScheme.secondaryContainer;
    if (sdgTheme != null && challenge.categories.isNotEmpty) {
      circleColor = sdgTheme.colorForSdgKey(challenge.categories.first);
    }

    Widget buildMetaInfo(IconData icon, String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // <-- 3. USING THE NEW PARAMETER
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      challenge.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Chip(
                          label: Text(challenge.calculateDifficulty(balance!)),
                          labelStyle: theme.textTheme.labelSmall,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        const Spacer(),
                        if (challenge.createdAt != null) ...[
                          buildMetaInfo(
                            Iconsax.calendar_1,
                            DateFormat('dd.MM.yyyy').format(challenge.createdAt!),
                          ),
                          const SizedBox(width: 12),
                        ],
                        buildMetaInfo(Iconsax.star, '${challenge.calculatePoints(balance)} Pts'), // PASS BALANCE
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}