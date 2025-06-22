import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports
import '../../../../core/utils/app_logger.dart';

// Home Provider & Entities
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/sdg_color_theme.dart';
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
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final sdgTheme = Theme.of(context).extension<SdgColorTheme>();

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
                const BackgroundImage(), // Aus Core importiert
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, // Startet unten
                        end: Alignment.topCenter,      // Geht nach oben
                        colors: [
                          // Startet unten mit einer deckenderen Farbe
                          AppColors.primaryBackground.withOpacity(0.9), // Dein dunkles Blau, fast deckend
                          AppColors.primaryBackground.withOpacity(0.7),
                          AppColors.primaryBackground.withOpacity(0.0), // Wird nach oben hin transparent
                        ],
                        stops: const [0.0, 0.5, 1.0], // Kontrolliert die Übergänge
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                      begin: Alignment.topCenter, // Startet oben
                      end: Alignment.bottomCenter,   // Geht nach unten
                      colors: [
                        AppColors.primaryBackground.withOpacity(0.6), // Oben etwas dunkler
                        AppColors.primaryBackground.withOpacity(0.0), // Wird nach unten transparent
                      ],
                      stops: const [0.0, 1.0], // Einfacher Übergang
                    ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Welcome, \n${authProvider.currentUser?.name ?? "User"}',
                            style: const TextStyle(fontFamily: 'OswaldRegular', color: Colors.white, fontSize: 30),
                          ),
                          const SizedBox(height: 10),
                          const ExpandableTextWidget(), // Aus Core importiert
                        ],
                      ),
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
            Padding(padding: const EdgeInsets.all(16.0), child: Center(child: Text(homeProvider.sdgItemsError!, style: const TextStyle(color: Colors.red))))
          else if (homeProvider.sdgNavItems.isNotEmpty)
              _buildSdgNavigationListView(context, homeProvider.sdgNavItems)
            else
              const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("No SDG items to display.", style: TextStyle(color: Colors.white70)))),


          // --- "To do" Challenges Preview ---
          _buildChallengePreviewList(
            context,
            title: "To do",
            isLoading: homeProvider.isLoadingOngoingPreviews,
            error: homeProvider.ongoingPreviewsError,
            challenges: homeProvider.ongoingChallengePreviews,
            navigateToFullList: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChallengeListScreen(initialTabIndex: 1),
                ),
              );
            },
          ),

          // --- "Completed" Challenges Preview ---
          _buildChallengePreviewList(
            context,
            title: "Completed",
            isLoading: homeProvider.isLoadingCompletedPreviews,
            error: homeProvider.completedPreviewsError,
            challenges: homeProvider.completedChallengePreviews,
            navigateToFullList: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChallengeListScreen(initialTabIndex: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Baut die horizontale Liste der SDG Icons
  void _navigateToSdgDetail(BuildContext context, String sdgId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SdgDetailScreen(sdgId: sdgId)),
    );
    AppLogger.debug("Navigating to SDG detail for: $sdgId");
  }

  // --- ANGEPASSTE METHODE ---
  Widget _buildSdgNavigationListView(BuildContext context, List<SdgListItemEntity> navItems) {
    if (navItems.isEmpty) {
      return const SizedBox.shrink(); // Nichts anzeigen, wenn keine Items vorhanden sind
    }

    // Aufteilung in zwei Reihen, falls gewünscht.
    // Du kannst dies auch anpassen, um z.B. nur eine scrollbare Reihe zu haben.
    final int itemsPerRow = (navItems.length / 2).ceil().clamp(1, 9); // Max 9 pro Reihe
    final List<SdgListItemEntity> row1Items = navItems.take(itemsPerRow).toList();
    final List<SdgListItemEntity> row2Items = navItems.skip(itemsPerRow).toList();

    Widget buildRow(List<SdgListItemEntity> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 60, // Höhe der Reihe
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index]; // item ist jetzt SdgListItemEntity
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                width: 45, // Breite des Icons
                child: GestureDetector(
                  // Verwende die ID von SdgListItemEntity für die Navigation
                  onTap: () => _navigateToSdgDetail(context, item.id), // Annahme: item.id ist "goal1" etc.
                  child: Image.asset(
                    item.listImageAssetPath, // Pfad aus SdgListItemEntity
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) { // Fallback für fehlende Bilder
                      return const Icon(Icons.broken_image, color: Colors.grey, size: 30);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        buildRow(row1Items),
        if (row2Items.isNotEmpty) buildRow(row2Items), // Zweite Reihe nur, wenn nötig
      ],
    );
  }

  // Baut eine Sektion für Challenge-Vorschauen (Ongoing oder Completed)
  Widget _buildChallengePreviewList(
      BuildContext context, {
        required String title,
        required bool isLoading,         // Vom HomeProvider
        required String? error,          // Vom HomeProvider
        required List<ChallengeEntity> challenges, // Vom HomeProvider
        required VoidCallback navigateToFullList,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: navigateToFullList,
                child: Text(
                  "See all",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary
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

  // Hilfsmethode für den Inhalt der Challenge-Liste (Laden, Fehler, Daten)
  Widget _buildChallengeContentItself(
      BuildContext context,
      bool isLoading,
      String? error,
      List<ChallengeEntity> challenges,
      ) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Passende Farbe
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (challenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No challenges in this section yet.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
          ),
        ),
      );
    }

    // Baue die Liste der Challenge-Karten
    return Column(
      children: challenges.map((challenge) {
        return ChallengePreviewCardWidget(
          challenge: challenge,
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
        );
      }).toList(),
    );
  }
}
