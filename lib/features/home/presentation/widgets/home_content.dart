import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/presentation/screens/challenge_details_screen.dart';
import '../../../challenges/presentation/screens/challenge_list_screen.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';
import '../../../profile/domain/utils/level_utils.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../profile/presentation/widgets/circular_profile_progress_widget.dart';
import '../../../sdg/presentation/screens/sdg_detail_screen.dart';
import '../../../sdg/presentation/screens/sdg_list_screen.dart';
import '../providers/home_provider.dart';
import 'home_dashboard_cards.dart';
import 'challenge_preview_card.dart';

class HomeContent extends StatelessWidget {
  final void Function(int pageIndex, {int? challengeTabIndex}) navigateToPage;

  const HomeContent({
    super.key,
    required this.navigateToPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthenticationProvider>();
    final profileProvider = context.watch<UserProfileProvider>();
    final homeProvider = context.watch<HomeProvider>();

    final userProfile = profileProvider.userProfile;
    final userName = userProfile?.name ?? authProvider.currentUser?.name ?? "User";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          children: [
            // --- 1. Minimalistischer Header ---
            _buildModernHeader(context, userName, userProfile),
            const SizedBox(height: 24),

            // --- 2. Impact-Statistiken ---
            _buildImpactStats(context, userProfile),
            const SizedBox(height: 24),

            // --- 3. Horizontale SDG-Karten ---
            _buildSectionHeader(context, "Spotlight on a Goal", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SdgListScreen()));
            }),
            const SizedBox(height: 12),
            // The carousel will now respect the ListView's padding.
            // We need to adjust its internal structure slightly.
            _buildSdgCarousel(context, homeProvider),
            const SizedBox(height: 24),

            // --- 4. VERTIKALE Challenge-Liste ---
            _buildSectionHeader(context, "Your Ongoing Challenges", () {
              navigateToPage(1, challengeTabIndex: 1);
            }),
            const SizedBox(height: 12),
            _buildChallengesList(context, homeProvider.ongoingChallengePreviews, homeProvider.isLoadingOngoingPreviews),
          ],
        ),
      ),
    );
  }

  // --- BUILD HELPER WIDGETS ---

  Widget _buildModernHeader(BuildContext context, String userName, UserProfileEntity? userProfile) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello,",
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant
              ),
            ),
            Text(
              userName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircularProfileProgressWidget(
          imageUrl: userProfile?.profileImageUrl,
          level: userProfile?.level ?? 1,
          progress: userProfile != null ? LevelUtils.calculateLevelData(userProfile.points).progress : 0.0,
          size: 50,
          userName: userName,
        )
      ],
    );
  }

  Widget _buildImpactStats(BuildContext context, UserProfileEntity? userProfile) {
    if (userProfile == null) return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatDisplayCard(
              value: userProfile.points.toString(),
              label: "Total Points",
              icon: Iconsax.star,
              iconColor: Colors.amber.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatDisplayCard(
              value: userProfile.level.toString(),
              label: "Your Level",
              icon: Iconsax.shield_tick,
              iconColor: Colors.blue.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAllTap) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        InkWell(
          onTap: onSeeAllTap,
          child: Text(
            "See all",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
          ),
        )
      ],
    );
  }

  Widget _buildSdgCarousel(BuildContext context, HomeProvider homeProvider) {
    final theme = Theme.of(context);
    if (homeProvider.isLoadingSdgItems) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
    if (homeProvider.sdgNavItems.isEmpty) return const SizedBox(height: 180, child: Center(child: Text("No SDGs found.")));

    return SizedBox(
      height: 180,
      child: CarouselView.weighted(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        itemSnapping: true,
        shrinkExtent: 500.0,
        flexWeights: const [1,1],
        onTap: (int index) {
          final item = homeProvider.sdgNavItems[index];
          Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => SdgDetailScreen(sdgId: item.id))
          );
        },
        children: homeProvider.sdgNavItems.map((item) {
            return DashboardCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(item.listImageAssetPath, height: 70, width: 70),
                  const SizedBox(height: 12),
                  Text(item.title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium)
                ],
              ),
            );
        }).toList(),
      ),
    );
  }

  Widget _buildChallengesList(BuildContext context, List<ChallengeEntity> challenges, bool isLoading) {
    final theme = Theme.of(context);
    if (isLoading) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator()));

    if (challenges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "Nice! You completed all your ongoing challenges. Time for more!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: challenges.map((challenge) {
        return ChallengePreviewCardWidget(
          challenge: challenge,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChallengeDetailsScreen(challengeId: challenge.id),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}