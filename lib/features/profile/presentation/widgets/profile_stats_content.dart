import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';
import '../../../../auth_wrapper.dart';
import '../../../../core/theme/sdg_color_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../sdg/domain/entities/sdg_list_item_entity.dart';
import '../../../sdg/presentation/providers/sdg_list_provider.dart';
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
    if (userProfile == null) {
      return Center(
        child: Text('Please log in to view your profile.', style: theme.textTheme.bodyLarge),
      );
    }
    final levelData = LevelUtils.calculateLevelData(userProfile.points);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildCustomHeader(context, userProfile, levelData),
          const SizedBox(height: 24),
          _buildStatsCards(context, userProfile),
          const SizedBox(height: 24),
          _buildUserDetailsCard(context, userProfile),
          const SizedBox(height: 24),
          Text("Your SDG Engagement", style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          StreamBuilder<Map<String, int>?>(
            stream: profileProvider.categoryCountsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SizedBox(height: 100, child: Center(child: Text('Error: ${snapshot.error}')));
              }
              final categoryCounts = snapshot.data;
              if (categoryCounts == null || categoryCounts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        "Complete challenges to see your SDG engagement stats here!",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                );
              }
              return _buildSdgEngagementList(context, categoryCounts);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSdgEngagementList(BuildContext context, Map<String, int> categoryCounts) {
    final theme = Theme.of(context);
    final sdgTheme = theme.extension<SdgColorTheme>()!;
    final sdgListProvider = context.watch<SdgListProvider>();
    final allSdgItems = sdgListProvider.sdgListItems;

    if (allSdgItems.isEmpty) return const SizedBox.shrink();

    final totalCount = categoryCounts.values.fold(0, (sum, count) => sum + count);
    final maxCount = categoryCounts.values.reduce(max); // Find the highest value

    final sortedEntries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: sortedEntries.map((entry) {
            final goalKey = entry.key;
            final count = entry.value;
            final percentage = (count / totalCount) * 100;
            final relativeBarWidth = count / maxCount; // The bar width relative to the max value

            final color = sdgTheme.colorForSdgKey(goalKey);
            final sdgItem = allSdgItems.firstWhere(
                  (item) => item.id == goalKey,
              orElse: () => SdgListItemEntity(id: goalKey, title: goalKey, listImageAssetPath: ''),
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            sdgItem.listImageAssetPath,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(Iconsax.global, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(sdgItem.title, style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // This is the relative bar that replaces the progress indicator
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: relativeBarWidth,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, UserProfileEntity userProfile, LevelData levelData) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                userProfile.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Iconsax.menu_1),
          onSelected: (value) async {
            // Store the context-dependent objects before any async operations.
            final authProvider = context.read<AuthenticationProvider>();
            final navigator = Navigator.of(context);

            if (value == 'edit') {
              navigator.push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            } else if (value == 'logout') {
              await authProvider.performSignOut();

              if (navigator.mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                      (Route<dynamic> route) => false,
                );
              }
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
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}