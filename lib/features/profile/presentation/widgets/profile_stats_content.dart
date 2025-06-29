import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Core Imports
import '/core/theme/sdg_color_theme.dart';

// Feature Imports
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileStatsContent extends StatelessWidget {
  const ProfileStatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthenticationProvider>();
    final profileProvider = context.watch<UserProfileProvider>();

    final UserProfileEntity? userProfile = profileProvider.userProfile;
    final SdgColorTheme? sdgTheme = theme.extension<SdgColorTheme>();

    if (profileProvider.isLoadingProfile && userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileProvider.profileError != null && userProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${profileProvider.profileError}',
              style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
        ),
      );
    }

    if (!authProvider.isLoggedIn || userProfile == null) {
      return Center(
        child: Text(
          'Please log in to view your profile.',
          style: theme.textTheme.bodyLarge, // OPTIMIERT
        ),
      );
    }

    final String? profilePicUrl = userProfile.profileImageUrl;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // --- User profile header ---
        SizedBox(
          height: MediaQuery.of(context).size.height / 3.5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (profilePicUrl != null && profilePicUrl.isNotEmpty)
                Image.network(
                  profilePicUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/start.png', fit: BoxFit.cover),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              else
                Image.asset('assets/images/start.png', fit: BoxFit.cover),
              // OPTIMIERT: Gradient verwendet Theme-Farbe
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        theme.scaffoldBackgroundColor,
                        theme.scaffoldBackgroundColor.withOpacity(0.0)
                      ],
                      stops: const [0.0, 0.9],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- User's basic information ---
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.name,
                // OPTIMIERT: Verwendet Text-Stil aus dem Theme
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildProfileInfoRow(context, Icons.email_outlined, userProfile.email ?? authProvider.currentUserEmail ?? 'N/A'),
              _buildProfileInfoRow(context, Icons.cake_outlined, '${userProfile.age} years old'),
              _buildProfileInfoRow(context, Icons.school_outlined, userProfile.studyField),
              _buildProfileInfoRow(context, Icons.account_balance_outlined, userProfile.school),
              const SizedBox(height: 16),
              Row(
                children: [
                  // OPTIMIERT: Die _buildStatChip-Methode verwendet jetzt Theme-Farben
                  _buildStatChip(context, "Points", userProfile.points.toString(), Icons.star, theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  _buildStatChip(context, "Level", userProfile.level.toString(), Icons.shield, theme.colorScheme.secondary),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 10),

        // --- Statistics section ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Your SDG Engagement",
            style: theme.textTheme.titleLarge, // OPTIMIERT
          ),
        ),
        const SizedBox(height: 10),

        // --- PieChart ---
        StreamBuilder<List<PieChartSectionData>?>(
          stream: profileProvider.pieChartDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SizedBox(height: 100, child: Center(child: Text('Error loading stats: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error))));
            }
            final pieData = snapshot.data;
            if (pieData == null || pieData.isEmpty) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "No completed challenges to show stats for yet.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), // OPTIMIERT
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: PieChart(
                  PieChartData(
                    sections: pieData,
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // --- SDG Color Legend ---
        if (sdgTheme != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: List.generate(17, (index) {
                final goalKey = 'goal${index + 1}';
                final color = sdgTheme.colorForSdgKey(goalKey);
                return Tooltip(
                  message: "SDG ${index + 1}",
                  child: Chip(
                    avatar: CircleAvatar(backgroundColor: color, radius: 6),
                    label: Text(goalKey.replaceFirst('goal', ''), style: theme.textTheme.labelSmall),
                    // OPTIMIERT: Verwendet eine semantische Container-Farbe
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 30),
      ],
    );
  }

  // OPTIMIERT: Diese Methode ist jetzt sauber und themenbasiert
  Widget _buildProfileInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  // OPTIMIERT: Diese Methode ist jetzt sauber und themenbasiert
  Widget _buildStatChip(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text('$label: $value', style: theme.textTheme.labelMedium),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}