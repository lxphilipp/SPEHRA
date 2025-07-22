// lib/features/profile/presentation/widgets/profile_stats_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/sdg_color_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/utils/level_utils.dart';
import 'circular_profile_progress_widget.dart';
import '../screens/edit_profile_screen.dart';

class ProfileStatsContent extends StatelessWidget {
  const ProfileStatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<UserProfileProvider>();
    final authProvider = context.watch<AuthenticationProvider>();

    if (profileProvider.isLoadingProfile && profileProvider.userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileProvider.profileError != null && profileProvider.userProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${profileProvider.profileError}',
              style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
        ),
      );
    }

    final userProfile = profileProvider.userProfile;
    final authUser = authProvider.currentUser;

    if (userProfile == null || authUser == null) {
      return Center(
        child: Text(
          'Please log in to view your profile.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    final levelData = LevelUtils.calculateLevelData(userProfile.points);
    final SdgColorTheme? sdgTheme = theme.extension<SdgColorTheme>();

    return SafeArea( child:  ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // --- NEW: Custom Header integrated into the content ---
        _buildCustomHeader(context, userProfile, levelData),
        const SizedBox(height: 24),

        // --- Stats Cards (Points & Level) ---
        _buildStatsCards(context, userProfile),
        const SizedBox(height: 24),

        // --- User Details Card ---
        _buildUserDetailsCard(context, userProfile),
        const SizedBox(height: 24),

        // --- Statistics Section ---
        Text("Your SDG Engagement", style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),

        // --- PieChart ---
        _buildPieChart(context, profileProvider),
        const SizedBox(height: 20),

        // --- SDG Color Legend ---
        if (sdgTheme != null)
          _buildSdgLegend(context, sdgTheme),

        const SizedBox(height: 30),
      ],
    )
    );
  }

  Widget _buildCustomHeader(BuildContext context, UserProfileEntity userProfile, LevelData levelData) {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthenticationProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.name, // <-- FIXED: Display user's name
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                userProfile.email ?? '', // <-- FIXED: Display user's email
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Iconsax.menu_1),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            } else if (value == 'logout') {
              authProvider.performSignOut();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                leading: Icon(Iconsax.edit),
                title: Text('Edit Profile'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Iconsax.logout),
                title: Text('Log out'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, UserProfileEntity userProfile) {
    final theme = Theme.of(context);
    final levelData = LevelUtils.calculateLevelData(userProfile.points);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircularProfileProgressWidget(
              imageUrl: userProfile.profileImageUrl,
              level: levelData.level,
              progress: levelData.progress,
              size: 60,
              userName: userProfile.name,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${userProfile.points} Points",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Level ${userProfile.level}",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard(BuildContext context, UserProfileEntity userProfile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, Iconsax.cake, '${userProfile.age} years old'),
            const Divider(height: 24),
            _buildInfoRow(context, Iconsax.teacher, userProfile.studyField),
            const Divider(height: 24),
            _buildInfoRow(context, Iconsax.building, userProfile.school),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, UserProfileProvider profileProvider) {
    final theme = Theme.of(context);
    return StreamBuilder<List<PieChartSectionData>?>(
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
                  "Complete challenges to see your SDG engagement stats here!",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: pieData,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSdgLegend(BuildContext context, SdgColorTheme sdgTheme) {
    final theme = Theme.of(context);
    return Padding(
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
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }),
      ),
    );
  }
}