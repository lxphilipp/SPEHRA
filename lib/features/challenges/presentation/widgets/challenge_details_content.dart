// Wird hier nicht direkt benötigt, aber oft in verwandten Screens
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core Widgets & Theme
import '/core/widgets/background_image.dart';
import '/core/theme/app_colors.dart'; // Für spezifische Farben
import '/core/theme/sdg_color_theme.dart';

// Feature Provider & Entities
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge_entity.dart';

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
    // Lade die Challenge-Details, wenn das Widget initialisiert wird
    // Verwende addPostFrameCallback, um sicherzustellen, dass der BuildContext verfügbar ist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Nur laden, wenn die selectedChallenge nicht bereits diese ID hat oder null ist
      final provider = Provider.of<ChallengeProvider>(context, listen: false);
      if (provider.selectedChallenge?.id != widget.challengeId || provider.selectedChallenge == null) {
        provider.fetchChallengeDetails(widget.challengeId);
      }
    });
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade700, // Etwas dunkler für deaktiviert
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), // Etwas mehr Padding
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text(label, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildCategoryImageWidget(ChallengeEntity challenge, ThemeData theme, SdgColorTheme? sdgTheme) {
    // TODO: categoryNames global oder über SDG-Provider bereitstellen
    List<String> categoryNames = List.generate(17, (i) => 'goal${i + 1}');
    int categoryIndex = -1;
    String imagePath = 'assets/images/default_sdg_placeholder.png'; // Fallback-Bild

    if (challenge.categories.isNotEmpty) {
      categoryIndex = categoryNames.indexOf(challenge.categories.first);
      if (categoryIndex != -1) {
        imagePath = 'assets/icons/17_SDG_Icons/${categoryIndex + 1}.png';
      }
    }

    return Image.asset(imagePath, width: 50, height: 50,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.eco, size: 50, color: sdgTheme?.defaultGoalColor ?? AppColors.defaultGoalColor),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sdgTheme = theme.extension<SdgColorTheme>();

    // Provider beobachten
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false); // listen:false für Aktionen

    final ChallengeEntity? challenge = challengeProvider.selectedChallenge;
    final bool isLoadingDetails = challengeProvider.isLoadingSelectedChallenge;
    final String? errorDetails = challengeProvider.selectedChallengeError;

    final bool isUpdatingStatus = challengeProvider.isUpdatingUserChallengeStatus;
    final String? statusError = challengeProvider.userChallengeStatusError;

    // Zeige Ladeindikator, während die Haupt-Challenge-Daten geladen werden
    if (isLoadingDetails && challenge?.id != widget.challengeId) {
      return const Center(child: CircularProgressIndicator());
    }

    // Zeige Fehler, wenn das Laden der Haupt-Challenge-Daten fehlschlug
    if (errorDetails != null && challenge?.id != widget.challengeId) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading challenge: $errorDetails',
              style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
        ),
      );
    }

    // Wenn keine Challenge-Daten vorhanden sind (sollte nach Fehlerbehandlung nicht oft passieren)
    if (challenge == null) {
      return const Center(
          child: Text('Challenge details not available.',
              style: TextStyle(color: AppColors.primaryText)));
    }

    // Ab hier wissen wir, dass `challenge` nicht null ist.
    bool isCompletedByUser = userProfileProvider.userProfile?.completedTasks.contains(challenge.id) ?? false;
    bool isOngoingByUser = userProfileProvider.userProfile?.ongoingTasks.contains(challenge.id) ?? false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Sektion mit Bild ---
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const BackgroundImage(), // Dein Core-Widget
                // Unterer Gradient für Textlesbarkeit
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          AppColors.primaryBackground.withOpacity(0.9),
                          AppColors.primaryBackground.withOpacity(0.7),
                          AppColors.primaryBackground.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Oberer Gradient für weicheren Übergang (optional)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          AppColors.primaryBackground.withOpacity(0.6),
                          AppColors.primaryBackground.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
                // Inhalt im Header
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCategoryImageWidget(challenge, theme, sdgTheme),
                      const SizedBox(height: 12),
                      Text(
                        challenge.title, // Titel direkt von der Challenge-Entity
                        style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryText, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text( // Kurze Beschreibung oder Teaser
                        challenge.description.length > 120
                            ? '${challenge.description.substring(0, 120)}...'
                            : challenge.description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primaryText.withOpacity(0.85)),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Detailinformationen ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 8),
                Text(challenge.description, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 24),
                Text('Your Task', style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 8),
                Text(challenge.task, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Points: ${challenge.points}', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
                    Text('Difficulty: ${challenge.difficulty}', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
                  ],
                ),
                if (challenge.categories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Related SDGs:', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: challenge.categories.map((catKey) {
                      final color = sdgTheme?.colorForSdgKey(catKey) ?? AppColors.defaultGoalColor;
                      return Chip(
                        avatar: CircleAvatar(backgroundColor: color, radius: 8),
                        label: Text(catKey, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      );
                    }).toList(),
                  )
                ]
              ],
            ),
          ),

          // --- Aktionsbuttons ---
          if (authProvider.isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  if (statusError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(statusError, style: TextStyle(color: theme.colorScheme.error, fontSize: 12), textAlign: TextAlign.center,),
                    ),
                  Row(
                    children: [
                      _buildActionButton(
                        label: isOngoingByUser ? 'Is Ongoing' : (isCompletedByUser ? 'Completed!' : 'Accept Challenge'),
                        backgroundColor: (isOngoingByUser || isCompletedByUser) ? Colors.grey.shade700 : theme.colorScheme.primary,
                        isLoading: isUpdatingStatus && !isOngoingByUser && !isCompletedByUser,
                        onPressed: (isOngoingByUser || isCompletedByUser) ? null : () {
                          challengeProvider.acceptChallenge(challenge.id).then((success) {
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Challenge added to your ongoing tasks!')));
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        label: isCompletedByUser ? 'Done!' : 'Mark as Completed',
                        backgroundColor: isCompletedByUser ? Colors.grey.shade700 : AppColors.accentGreen,
                        isLoading: isUpdatingStatus && !isCompletedByUser,
                        onPressed: isCompletedByUser ? null : () {
                          challengeProvider.completeChallenge(challenge.id).then((success) {
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Great job! Challenge marked as completed.')));
                              Navigator.pop(context);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isOngoingByUser && !isCompletedByUser)
                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(
                        label: 'Remove from Ongoing',
                        backgroundColor: theme.colorScheme.error.withOpacity(0.8),
                        isLoading: isUpdatingStatus,
                        onPressed: () {
                          challengeProvider.removeChallengeFromOngoing(challenge.id).then((success) {
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Challenge removed from ongoing tasks.')));
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 30), // Platz am Ende
        ],
      ),
    );
  }
}