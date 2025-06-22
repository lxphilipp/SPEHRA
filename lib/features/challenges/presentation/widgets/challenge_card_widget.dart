import 'package:flutter/material.dart';
import '/core/theme/sdg_color_theme.dart';
import '/core/theme/app_colors.dart'; // Für Fallback-Farben
// Importiere die passende Entity (ChallengeEntity oder ChallengePreviewEntity)
import '../../domain/entities/challenge_entity.dart'; // Oder ChallengePreviewEntity
import '../screens/challenge_details_screen.dart'; // Für Navigation

class ChallengeCardWidget extends StatelessWidget {
  // Nimmt entweder ChallengeEntity oder ChallengePreviewEntity entgegen
  final ChallengeEntity challenge; // Oder ChallengePreviewEntity
  final SdgColorTheme? sdgTheme;

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
    this.sdgTheme, // Kann vom aufrufenden Widget übergeben werden
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Hole SdgColorTheme, falls nicht übergeben
    final SdgColorTheme? effectiveSdgTheme = sdgTheme ?? Theme.of(context).extension<SdgColorTheme>();

    Color circleColor = AppColors.defaultGoalColor; // Fallback
    if (effectiveSdgTheme != null && challenge.categories.isNotEmpty) {
      // Nimmt die erste Kategorie für die Farbe des Kreises
      circleColor = effectiveSdgTheme.colorForSdgKey(challenge.categories.first);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardTheme.color ?? AppColors.cardBackground,
      shape: theme.cardTheme.shape,
      elevation: theme.cardTheme.elevation,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailsScreen(
                challengeId: challenge.id,
                // initialTitle: challenge.title, // Optional für schnelleres Anzeigen
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10), // Für den InkWell-Effekt
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListTile(
            leading: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
            ),
            title: Text(
              challenge.title,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              challenge.difficulty,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche 1.png', // Dein Punkte-Icon
                  width: 20,
                  height: 20,
                  color: theme.iconTheme.color,
                ),
                const SizedBox(height: 4),
                Text(
                  '${challenge.points} Pts',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}