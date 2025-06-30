import 'package:flutter/material.dart';
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

    Color circleColor = theme.colorScheme.secondaryContainer;
    if (challenge.categories.isNotEmpty && sdgTheme != null) {
      circleColor = sdgTheme.colorForSdgKey(challenge.categories.first);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 35, // Größe beibehalten
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
          ),
        ),
        title: Text(
          challenge.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          challenge.difficulty,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche 1.png',
                color: theme.iconTheme.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.points.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
}