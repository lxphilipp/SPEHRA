import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/background_image.dart';
import '../../../../core/widgets/expandable_text_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/presentation/screens/challenge_details_screen.dart';
import '../../../challenges/presentation/screens/challenge_list_screen.dart';
import '../../../sdg/domain/entities/sdg_list_item_entity.dart';
import '../../../sdg/presentation/screens/sdg_detail_screen.dart';
import '../providers/home_provider.dart';
import 'challenge_preview_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme am Anfang holen
    final authProvider = context.watch<AuthenticationProvider>();
    final homeProvider = context.watch<HomeProvider>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Sektion ---
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const BackgroundImage(),
                // OPTIMIERT: Gradient verwendet jetzt die Hintergrundfarbe aus dem Theme
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withOpacity(0.9),
                          theme.scaffoldBackgroundColor.withOpacity(0.7),
                          theme.scaffoldBackgroundColor.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // OPTIMIERT: Verwendet einen Text-Stil aus dem Theme
                        Text(
                          'Welcome, \n${authProvider.currentUser?.name ?? "User"}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontFamily: 'OswaldRegular',
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const ExpandableTextWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- SDG Icon Navigation ---
          if (homeProvider.isLoadingSdgItems)
            const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()))
          else if (homeProvider.sdgItemsError != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              // OPTIMIERT: Verwendet Fehlerfarbe und Text-Stil aus dem Theme
              child: Center(
                child: Text(
                  homeProvider.sdgItemsError!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            )
          else if (homeProvider.sdgNavItems.isNotEmpty)
              _buildSdgNavigationListView(context, homeProvider.sdgNavItems)
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                // OPTIMIERT: Verwendet eine semantische Farbe für den Hinweis
                child: Center(
                  child: Text(
                    "No SDG items to display.",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),

          // --- Challenge Previews ---
          _buildChallengePreviewList(
            context,
            title: "To do",
            isLoading: homeProvider.isLoadingOngoingPreviews,
            error: homeProvider.ongoingPreviewsError,
            challenges: homeProvider.ongoingChallengePreviews,
            navigateToFullList: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengeListScreen(initialTabIndex: 1)));
            },
          ),
          _buildChallengePreviewList(
            context,
            title: "Completed",
            isLoading: homeProvider.isLoadingCompletedPreviews,
            error: homeProvider.completedPreviewsError,
            challenges: homeProvider.completedChallengePreviews,
            navigateToFullList: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengeListScreen(initialTabIndex: 2)));
            },
          ),
        ],
      ),
    );
  }

  void _navigateToSdgDetail(BuildContext context, String sdgId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SdgDetailScreen(sdgId: sdgId)));
  }

  Widget _buildSdgNavigationListView(BuildContext context, List<SdgListItemEntity> navItems) {
    // ... (Diese Methode bleibt unverändert, sie verwendet bereits themenkonforme Fallbacks)
    final theme = Theme.of(context);
    final int itemsPerRow = (navItems.length / 2).ceil().clamp(1, 9);
    final List<SdgListItemEntity> row1Items = navItems.take(itemsPerRow).toList();
    final List<SdgListItemEntity> row2Items = navItems.skip(itemsPerRow).toList();

    Widget buildRow(List<SdgListItemEntity> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                width: 45,
                child: GestureDetector(
                  onTap: () => _navigateToSdgDetail(context, item.id),
                  child: Image.asset(
                    item.listImageAssetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, color: theme.colorScheme.onSurfaceVariant, size: 30);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return Column(children: [buildRow(row1Items), if (row2Items.isNotEmpty) buildRow(row2Items)]);
  }

  Widget _buildChallengePreviewList(BuildContext context, {required String title, required bool isLoading, required String? error, required List<ChallengeEntity> challenges, required VoidCallback navigateToFullList}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              GestureDetector(
                onTap: navigateToFullList,
                child: Text(
                  "See all",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildChallengeContentItself(context, isLoading, error, challenges),
        )
      ],
    );
  }

  Widget _buildChallengeContentItself(BuildContext context, bool isLoading, String? error, List<ChallengeEntity> challenges) {
    final theme = Theme.of(context);
    if (isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(error, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))));
    }
    if (challenges.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No challenges in this section yet.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))));
    }
    return Column(
      children: challenges.map((challenge) {
        return ChallengePreviewCardWidget(challenge: challenge, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengeDetailsScreen(challengeId: challenge.id))));
      }).toList(),
    );
  }
}