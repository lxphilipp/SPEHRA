import 'package:flutter/material.dart';
import '/core/theme/sdg_color_theme.dart';
// Importiere die passende Entity (ChallengeEntity oder ChallengePreviewEntity)
import '../../domain/entities/challenge_entity.dart';
import '../screens/challenge_details_screen.dart'; // Für Navigation

class ChallengeCardWidget extends StatelessWidget {
  final ChallengeEntity challenge;

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
    // Der sdgTheme Parameter wurde entfernt.
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Hole das SdgColorTheme direkt und nur aus dem Kontext.
    final sdgTheme = theme.extension<SdgColorTheme>();

    // OPTIMIERT: Bestimme die Farbe für den Kreis.
    // Der Fallback ist jetzt eine semantische Farbe aus dem ColorScheme.
    Color circleColor = theme.colorScheme.secondaryContainer; // Guter, neutraler Fallback
    if (sdgTheme != null && challenge.categories.isNotEmpty) {
      circleColor = sdgTheme.colorForSdgKey(challenge.categories.first);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // OPTIMIERT: Kein Fallback mehr nötig. Das Card-Theme ist im AppTheme definiert.
      // Die Farbe kommt jetzt zuverlässig von `theme.cardTheme.color`.
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailsScreen(
                challengeId: challenge.id,
              ),
            ),
          );
        },
        // Der Radius wird idealerweise auch vom CardTheme übernommen.
        borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)
            ?.borderRadius
            .resolve(Directionality.of(context)),
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
              style: theme.textTheme.titleMedium, // Farbe kommt vom Theme
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              challenge.difficulty,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant, // Perfekt für unauffälligen Text
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche 1.png',
                  width: 20,
                  height: 20,
                  // Die Farbe wird korrekt vom IconTheme der AppBar oder global geerbt.
                  color: theme.iconTheme.color,
                ),
                const SizedBox(height: 4),
                Text(
                  '${challenge.points} Pts',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}