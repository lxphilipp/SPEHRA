import 'package:flutter/material.dart';
import '/features/challenges/domain/entities/challenge_entity.dart'; // Importiere deine ChallengeEntity
import '/core/theme/app_colors.dart'; // Für Fallback-Farben
import '/core/theme/sdg_color_theme.dart'; // Für SDG-Farben über Theme

class ChallengePreviewCardWidget extends StatelessWidget {
  final ChallengeEntity challenge; // Nimmt eine ChallengeEntity entgegen
  final VoidCallback onTap;

  const ChallengePreviewCardWidget({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SdgColorTheme? sdgTheme = theme.extension<SdgColorTheme>();

    // Bestimme die Farbe für den SDG-Kreis
    Color circleColor = AppColors.defaultGoalColor; // Fallback
    if (challenge.categories.isNotEmpty && sdgTheme != null) {
      // Nimmt die erste Kategorie für die Farbe der Kachel-Vorschau
      circleColor = sdgTheme.colorForSdgKey(challenge.categories.first);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0), // Etwas Abstand zwischen den Karten
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? AppColors.cardBackground, // Farbe aus dem Theme oder Fallback
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [ // Optional: Ein leichter Schatten für mehr Tiefe
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material( // Material für den InkWell-Effekt
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0), // Passt zum Container-Radius
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Angepasstes Padding
            child: Row(
              children: [
                // SDG-Farbkreis
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                  ),
                ),
                const SizedBox(width: 12), // Abstand zwischen Kreis und Text

                // Titel und Schwierigkeit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        challenge.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface, // Farbe aus ColorScheme
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        challenge.difficulty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (theme.colorScheme.onSurface).withOpacity(0.7), // Etwas gedämpfter
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12), // Abstand zum Trailing-Element

                // Punkte-Anzeige
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      // Dein SDG-App Icon oder ein anderes passendes Icon
                      child: Image.asset(
                        'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche 1.png',
                        color: theme.iconTheme.color, // Farbe aus dem Theme
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.points.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}