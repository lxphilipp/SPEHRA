import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Core Imports
import '/core/theme/app_colors.dart'; // Für Fallback-Farben
import '/core/theme/sdg_color_theme.dart'; // Für SDG-Farben in der Legende (optional)

// Feature Imports
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/user_profile_entity.dart';


class ProfileStatsContent extends StatelessWidget {
  const ProfileStatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);

    final UserProfileEntity? userProfile = profileProvider.userProfile;
    final SdgColorTheme? sdgTheme = Theme.of(context).extension<SdgColorTheme>();


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
      return const Center(
        child: Text(
          'Please log in to view your profile.',
          style: TextStyle(color: AppColors.primaryText), // Besser: theme.colorScheme.onBackground
        ),
      );
    }

    String? profilePicUrl = userProfile.profileImageUrl;

    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        // User profile header
        SizedBox(
          height: MediaQuery.of(context).size.height / 3.5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (profilePicUrl != null && profilePicUrl.isNotEmpty)
                Image.network(profilePicUrl, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/start.png', fit: BoxFit.cover),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ));
                  },
                )
              else
                Image.asset('assets/images/start.png', fit: BoxFit.cover),
              // Gradient Overlays
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.center,
                      colors: [ AppColors.primaryBackground.withOpacity(0.8), AppColors.primaryBackground.withOpacity(0.0)],
                      stops: const [0.0, 0.7], // Gradient etwas höher ziehen
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // User's basic information
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.name, // Titel ist der Name des Users
                style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16), // Mehr Abstand
              _buildProfileInfoRow(context, Icons.email_outlined, userProfile.email ?? authProvider.currentUserEmail ?? 'N/A'),
              _buildProfileInfoRow(context, Icons.cake_outlined, '${userProfile.age} years old'),
              _buildProfileInfoRow(context, Icons.school_outlined, userProfile.studyField),
              _buildProfileInfoRow(context, Icons.account_balance_outlined, userProfile.school),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatChip(context, "Points", userProfile.points.toString(), Icons.star_border_purple500_outlined, theme.colorScheme.primary),
                  _buildStatChip(context, "Level", userProfile.level.toString(), Icons.military_tech_outlined, theme.colorScheme.secondary),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Statistics section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Your SDG Engagement", // Aussagekräftigerer Titel
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
          ),
        ),
        const SizedBox(height: 10),

        // PieChart
        StreamBuilder<List<PieChartSectionData>?>(
          stream: profileProvider.pieChartDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && (!snapshot.hasData || snapshot.data == null)) {
              return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SizedBox(height: 100, child: Center(child: Text('Error loading stats: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error))));
            }
            final pieData = snapshot.data;
            if (pieData == null || pieData.isEmpty) {
              return const SizedBox(
                height: 150, // Höhe geben, damit der Text Platz hat
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No completed challenges to show stats for yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.primaryText)), // Besser: theme.colorScheme.onSurfaceVariant
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
                    centerSpaceRadius: 60, // Größerer Innenkreis
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Optional: Interaktion bei Touch
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // SDG Color Legend (optional, wenn das PieChart nicht selbsterklärend genug ist)
        if (sdgTheme != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 6.0, // Weniger Abstand
              runSpacing: 6.0,
              alignment: WrapAlignment.center,
              children: List.generate(17, (index) {
                final goalKey = 'goal${index + 1}';
                final color = sdgTheme.colorForSdgKey(goalKey);
                // Zeige nur Chips für Farben, die im PieChart vorkommen könnten
                // oder zeige alle als Legende. Fürs Erste alle:
                return Tooltip( // Tooltip für den vollen Namen
                  message: "SDG ${index+1}", // TODO: Hier den echten Titel des SDGs anzeigen
                  child: Chip(
                    avatar: CircleAvatar(backgroundColor: color, radius: 6),
                    label: Text(goalKey.replaceFirst('goal', ''), style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant)),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 30), // Platz am Ende
      ],
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primaryText))),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text('$label: $value', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
      backgroundColor: color.withOpacity(0.2), // Leichter Hintergrund für den Chip
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}