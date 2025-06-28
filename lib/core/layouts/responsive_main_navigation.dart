import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Importiere deine Haupt-Screens
import 'package:flutter_sdg/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_sdg/features/challenges/presentation/screens/challenge_list_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/combined_chat_screen.dart'; // Der Screen mit der TabBar
import 'package:flutter_sdg/features/profile/presentation/screens/profile_stats_screen.dart';

/// Dies ist die Haupt-Navigationshülle der App.
/// Sie wechselt zwischen einer NavigationBar (unten) für mobile Geräte
/// und einer NavigationRail (seitlich) für Tablets und Desktops.
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
    ProfileStatsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // --- BREAKPOINT: Mobil (< 600px) ---
        if (constraints.maxWidth < 600) {
          // Für schmale Bildschirme: Scaffold mit NavigationBar unten.
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: _navDestinations,
            ),
          );
        }
        // --- BREAKPOINT: Tablet & Desktop (>= 600px) ---
        else {
          // Für breitere Bildschirme: Scaffold mit NavigationRail an der Seite.
          return Scaffold(
            body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: constraints.maxWidth < 840
                        ? NavigationRailLabelType.selected
                        : NavigationRailLabelType.all,
                    destinations: _navRailDestinations,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ],
              )
          );
        }
      },
    );
  }

  // Definitionen der Navigationsziele, um den Code sauber zu halten.
  static const List<NavigationDestination> _navDestinations = [
    NavigationDestination(
      selectedIcon: Icon(Iconsax.home_15),
      icon: Icon(Iconsax.home),
      label: 'Home',
    ),
    NavigationDestination(
      selectedIcon: Icon(Iconsax.cup5),
      icon: Icon(Iconsax.cup),
      label: 'Challenges',
    ),
    NavigationDestination(
      selectedIcon: Icon(Iconsax.message5),
      icon: Icon(Iconsax.message),
      label: 'Chat',
    ),
    NavigationDestination(
      selectedIcon: Icon(Iconsax.user_octagon),
      icon: Icon(Iconsax.user_octagon),
      label: 'Profile',
    ),
  ];

  static const List<NavigationRailDestination> _navRailDestinations = [
    NavigationRailDestination(
      selectedIcon: Icon(Iconsax.home_15),
      icon: Icon(Iconsax.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      selectedIcon: Icon(Iconsax.cup5),
      icon: Icon(Iconsax.cup),
      label: Text('Challenges'),
    ),
    NavigationRailDestination(
      selectedIcon: Icon(Iconsax.message5),
      icon: Icon(Iconsax.message),
      label: Text('Chat'),
    ),
    NavigationRailDestination(
      selectedIcon: Icon(Iconsax.user_octagon),
      icon: Icon(Iconsax.user_octagon),
      label: Text('Profile'),
    ),
  ];
}