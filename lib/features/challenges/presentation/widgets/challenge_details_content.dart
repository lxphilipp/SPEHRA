// lib/features/challenges/presentation/widgets/challenge_details_content.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core Widgets & Theme
import '/core/widgets/background_image.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChallengeProvider>(context, listen: false);
      if (provider.selectedChallenge?.id != widget.challengeId || provider.selectedChallenge == null) {
        provider.fetchChallengeDetails(widget.challengeId);
      }
    });
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    ButtonStyle? style,
    bool isLoading = false,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: style, // Der Stil wird von außen übergeben oder vom Theme geerbt.
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2), // Farbe kommt vom Button-Theme
        )
            : Text(label, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildCategoryImageWidget(ChallengeEntity challenge, ThemeData theme) {
    final sdgTheme = theme.extension<SdgColorTheme>();
    // ... (Logik zur Bildpfad-Bestimmung bleibt gleich)
    List<String> categoryNames = List.generate(17, (i) => 'goal${i + 1}');
    int categoryIndex = -1;
    String imagePath = 'assets/images/default_sdg_placeholder.png';

    if (challenge.categories.isNotEmpty) {
      categoryIndex = categoryNames.indexOf(challenge.categories.first);
      if (categoryIndex != -1) {
        imagePath = 'assets/icons/17_SDG_Icons/${categoryIndex + 1}.png';
      }
    }

    return Image.asset(
      imagePath,
      width: 50,
      height: 50,
      // OPTIMIERT: Fallback-Farbe aus dem Theme beziehen
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.eco,
        size: 50,
        color: sdgTheme?.defaultGoalColor ?? theme.colorScheme.secondaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sdgTheme = theme.extension<SdgColorTheme>();

    final challengeProvider = context.watch<ChallengeProvider>();
    final userProfileProvider = context.watch<UserProfileProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    final ChallengeEntity? challenge = challengeProvider.selectedChallenge;

    // ... (Lade- und Fehler-Logik bleibt gleich)
    if (challengeProvider.isLoadingSelectedChallenge && challenge?.id != widget.challengeId) {
      return const Center(child: CircularProgressIndicator());
    }
    if (challengeProvider.selectedChallengeError != null && challenge?.id != widget.challengeId) {
      return Center(child: Text('Error: ${challengeProvider.selectedChallengeError}', style: TextStyle(color: theme.colorScheme.error)));
    }
    if (challenge == null) {
      return Center(child: Text('Challenge details not available.', style: TextStyle(color: theme.colorScheme.onSurface)));
    }

    final bool isCompletedByUser = userProfileProvider.userProfile?.completedTasks.contains(challenge.id) ?? false;
    final bool isOngoingByUser = userProfileProvider.userProfile?.ongoingTasks.contains(challenge.id) ?? false;
    final bool isActionLoading = challengeProvider.isUpdatingUserChallengeStatus;


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Sektion ---
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const BackgroundImage(),
                // OPTIMIERT: Gradienten verwenden Farben aus dem ColorScheme
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          theme.colorScheme.surface.withOpacity(0.9),
                          theme.colorScheme.surface.withOpacity(0.0),
                        ],
                        stops: const [0.0, 1.0],
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
                      _buildCategoryImageWidget(challenge, theme),
                      const SizedBox(height: 12),
                      // OPTIMIERT: Textfarben aus dem Theme
                      Text(
                        challenge.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.description.length > 120 ? '${challenge.description.substring(0, 120)}...' : challenge.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.85),
                        ),
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
                // OPTIMIERT: Alle Textfarben aus dem Theme
                Text('Description', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(challenge.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                Text('Your Task', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(challenge.task, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Points: ${challenge.points}', style: theme.textTheme.titleMedium),
                    Text('Difficulty: ${challenge.difficulty}', style: theme.textTheme.titleMedium),
                  ],
                ),
                if (challenge.categories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Related SDGs:', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: challenge.categories.map((catKey) {
                      // OPTIMIERT: Fallback-Farbe aus dem Theme
                      final color = sdgTheme?.colorForSdgKey(catKey) ?? theme.colorScheme.secondaryContainer;
                      return Chip(
                        avatar: CircleAvatar(backgroundColor: color, radius: 8),
                        label: Text(catKey, style: theme.textTheme.labelSmall),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                  if (challengeProvider.userChallengeStatusError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        challengeProvider.userChallengeStatusError!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Row(
                    children: [
                      // Accept / Ongoing / Completed Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isActionLoading || isOngoingByUser || isCompletedByUser
                              ? null
                              : () => challengeProvider.acceptChallenge(challenge.id),
                          child: isActionLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(isOngoingByUser
                              ? 'Ongoing'
                              : (isCompletedByUser ? 'Completed!' : 'Accept Challenge')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Complete Button
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                          ),
                          onPressed: isActionLoading || isCompletedByUser
                              ? null
                              : () => challengeProvider.completeChallenge(challenge.id),
                          child: isActionLoading && !isOngoingByUser
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(isCompletedByUser ? 'Done!' : 'Mark as Completed'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Remove from Ongoing Button
                  if (isOngoingByUser && !isCompletedByUser)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.errorContainer,
                          foregroundColor: theme.colorScheme.onErrorContainer,
                        ),
                        onPressed: isActionLoading
                            ? null
                            : () => challengeProvider.removeChallengeFromOngoing(challenge.id),
                        child: isActionLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Remove from Ongoing'),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}