import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/features/challenges/domain/entities/challenge_entity.dart';
import '/core/theme/sdg_color_theme.dart';

class ChallengePreviewCardWidget extends StatelessWidget {
  final ChallengeEntity challenge;
  final VoidCallback onTap;

  const ChallengePreviewCardWidget({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sdgTheme = theme.extension<SdgColorTheme>();

    Color categoryColor = theme.colorScheme.secondaryContainer;
    if (challenge.categories.isNotEmpty && sdgTheme != null) {
      categoryColor = sdgTheme.colorForSdgKey(challenge.categories.first);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColor.withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: categoryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // CORRECTION: Use getter
                      challenge.calculatedDifficulty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.star, color: Colors.amber, size: 20),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        // CORRECTION: Use getter
                        challenge.calculatedPoints.toString(),
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                        maxLines: 1,
                      ),
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