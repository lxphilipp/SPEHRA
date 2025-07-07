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

class ResponsiveMainNavigation extends StatefulWidget {
  const ResponsiveMainNavigation({super.key});

  @override
  State<ResponsiveMainNavigation> createState() => _ResponsiveMainNavigationState();
}

class _ResponsiveMainNavigationState extends State<ResponsiveMainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    ChallengeListScreen(),
    CombinedChatScreen(),
    NewsScreen(),
    ProfileStatsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: _buildMobileDestinations(),
            ),
          );
        } else {
          // Desktop/Tablet Ansicht
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
                  // HIER IST DIE ÄNDERUNG: Aufruf der neuen Methode
                  destinations: _buildDesktopDestinations(),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// Baut die Navigationsziele für die mobile Ansicht (NavigationBar).
  List<NavigationDestination> _buildMobileDestinations() {
    return [
      const NavigationDestination(icon: Icon(Iconsax.home), selectedIcon: Icon(Iconsax.home_15), label: 'Home'),
      const NavigationDestination(icon: Icon(Iconsax.cup), selectedIcon: Icon(Iconsax.cup5), label: 'Challenges'),
      const NavigationDestination(icon: Icon(Iconsax.message), selectedIcon: Icon(Iconsax.message5), label: 'Chat'),
      const NavigationDestination(icon: Icon(Iconsax.global), selectedIcon: Icon(Iconsax.global5), label: 'News'),
      const NavigationDestination(icon: Icon(Iconsax.user_octagon), selectedIcon: Icon(Iconsax.user_octagon1), label: 'Profile')
    ];
  }

  /// Baut die Navigationsziele für die Desktop-Ansicht (NavigationRail).
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


class _ProfileNavWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isMobile;
  final bool isSelected;

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