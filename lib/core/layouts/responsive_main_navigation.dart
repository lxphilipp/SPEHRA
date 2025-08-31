import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:flutter_sdg/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_sdg/features/challenges/presentation/screens/challenge_list_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/combined_chat_screen.dart';
import 'package:flutter_sdg/features/news/presentation/screens/news_screen.dart';
import 'package:flutter_sdg/features/profile/presentation/screens/profile_stats_screen.dart';

// Profile Widgets & Provider
import 'package:flutter_sdg/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter_sdg/features/profile/domain/entities/user_profile_entity.dart';
import 'package:flutter_sdg/features/profile/domain/utils/level_utils.dart';
import 'package:flutter_sdg/features/profile/presentation/widgets/circular_profile_progress_widget.dart';

/// A responsive main navigation widget that adapts to different screen sizes.
///
/// On mobile devices, it displays a [BottomNavigationBar]. On larger screens,
/// it shows a [NavigationRail].
class ResponsiveMainNavigation extends StatefulWidget {
  /// Creates a [ResponsiveMainNavigation] widget.
  const ResponsiveMainNavigation({super.key});

  @override
  State<ResponsiveMainNavigation> createState() => _ResponsiveMainNavigationState();
}

class _ResponsiveMainNavigationState extends State<ResponsiveMainNavigation> {
  int _selectedIndex = 0;
  // This now holds the dynamic configuration for our pages.
  late List<Widget> _pages;
  // A key to ensure the ChallengeListScreen rebuilds with the new initialTabIndex when needed.
  int _challengeListKey = 0;

  @override
  void initState() {
    super.initState();
    _buildPages(); // Initial page setup
  }

  /// Constructs the list of main pages for the navigation.
  ///
  /// This method is called to rebuild the page list, especially when
  /// navigating to a specific tab on the ChallengeListScreen.
  void _buildPages({int challengeTabIndex = 0}) {
    // The list of pages is now built dynamically.
    _pages = <Widget>[
      // Pass the navigation callback to the HomeScreen.
      HomeScreen(navigateToPage: _navigateToPage),
      ChallengeListScreen(
        // The key ensures that the widget is completely rebuilt if the key changes,
        // which allows us to reliably set a new initialTabIndex.
        key: ValueKey(_challengeListKey),
        initialTabIndex: challengeTabIndex,
      ),
      const CombinedChatScreen(),
      const NewsScreen(),
      const ProfileStatsScreen(),
    ];
  }

  /// The core navigation function that handles switching pages and
  /// passing parameters to them.
  void _navigateToPage(int pageIndex, {int? challengeTabIndex}) {
    setState(() {
      // If we are specifically navigating to the challenges page (index 1)
      // and a specific tab index is provided, we need to rebuild the pages.
      if (pageIndex == 1 && challengeTabIndex != null) {
        _challengeListKey++; // Changing the key forces a widget rebuild.
        _buildPages(challengeTabIndex: challengeTabIndex);
      }
      _selectedIndex = pageIndex;
    });
  }

  /// Callback for when a user taps on a destination in the
  /// NavigationBar or NavigationRail.
  void _onDestinationSelected(int index) {
    // Standard navigation simply calls our main navigation function.
    _navigateToPage(index);
  }

  /// Builds the header for the NavigationRail (desktop view).
  Widget _buildRailHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Image.asset(
        'assets/logo/Logo-Bild.png',
        width: 40,
        height: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // --- Mobile View ---
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages, // Use the stateful _pages list
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: _buildMobileDestinations(),
            ),
          );
        } else {
          // --- Desktop/Tablet View ---
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: constraints.maxWidth < 840
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  leading: _buildRailHeader(),
                  destinations: _buildDesktopDestinations(),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages, // Use the stateful _pages list
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// Builds the navigation destinations for the mobile view (NavigationBar).
  List<NavigationDestination> _buildMobileDestinations() {
    return [
      const NavigationDestination(icon: Icon(Iconsax.home), selectedIcon: Icon(Iconsax.home_15), label: 'Home'),
      const NavigationDestination(icon: Icon(Iconsax.cup), selectedIcon: Icon(Iconsax.cup5), label: 'Challenges'),
      const NavigationDestination(icon: Icon(Iconsax.message), selectedIcon: Icon(Iconsax.message5), label: 'Chat'),
      const NavigationDestination(icon: Icon(Iconsax.global), selectedIcon: Icon(Iconsax.global5), label: 'News'),
      const NavigationDestination(icon: Icon(Iconsax.user_octagon), selectedIcon: Icon(Iconsax.user_octagon1), label: 'Profile')
    ];
  }

  /// Builds the navigation destinations for the desktop view (NavigationRail).
  List<NavigationRailDestination> _buildDesktopDestinations() {
    return const [
      NavigationRailDestination(icon: Icon(Iconsax.home), selectedIcon: Icon(Iconsax.home_15), label: Text('Home')),
      NavigationRailDestination(icon: Icon(Iconsax.cup), selectedIcon: Icon(Iconsax.cup5), label: Text('Challenges')),
      NavigationRailDestination(icon: Icon(Iconsax.message), selectedIcon: Icon(Iconsax.message5), label: Text('Chat')),
      NavigationRailDestination(icon: Icon(Iconsax.global), selectedIcon: Icon(Iconsax.global5), label: Text('News')),
      NavigationRailDestination(icon: Icon(Iconsax.user_octagon), selectedIcon: Icon(Iconsax.user_octagon1), label: Text('Profile')),
    ];
  }
}


/// A private widget to display the user's profile picture and level in the navigation.
class _ProfileNavWidget extends StatelessWidget {
  /// The callback to be executed when the widget is tapped.
  final VoidCallback onTap;

  /// Whether the widget is displayed in a mobile layout.
  final bool isMobile;

  /// Whether the widget is currently selected.
  final bool isSelected;

  /// Creates a [_ProfileNavWidget].
  const _ProfileNavWidget({
    required this.onTap,
    required this.isMobile,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final UserProfileEntity? userProfile = profileProvider.userProfile;

        if (userProfile == null) {
          return IconButton(
            icon: Icon(isSelected ? Iconsax.user_octagon5 : Iconsax.user_octagon),
            onPressed: onTap,
          );
        }

        final levelData = LevelUtils.calculateLevelData(userProfile.points);
        final size = 50.0;

        return InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: CircularProfileProgressWidget(
            imageUrl: userProfile.profileImageUrl,
            level: levelData.level,
            progress: levelData.progress,
            size: size,
          ),
        );
      },
    );
  }
}