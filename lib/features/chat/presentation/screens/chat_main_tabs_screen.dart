import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // Stelle sicher, dass du dieses Paket in pubspec.yaml hast

// Die Screens, die in den Tabs angezeigt werden sollen
import 'chat_home_screen.dart';      // Für 1-zu-1 Chats (sollte ChatRoomListScreen sein)
import 'group_chat_list_screen.dart'; // Für Gruppenchats
import 'user_search_screen.dart';      // Für Kontakte/User-Suche

import '../../../../core/utils/app_logger.dart';

class ChatMainTabsScreen extends StatefulWidget {
  const ChatMainTabsScreen({super.key});

  @override
  State<ChatMainTabsScreen> createState() => _ChatMainTabsScreenState();
}

class _ChatMainTabsScreenState extends State<ChatMainTabsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Die Screens, die in den Tabs angezeigt werden.
  // Stelle sicher, dass die Namen mit deinen tatsächlichen Screen-Dateien übereinstimmen.
  final List<Widget> _screens = [
    const ChatHomeScreen(),      // Tab 0: Liste der 1-zu-1 Chats
    const GroupChatListScreen(), // Tab 1: Liste der Gruppenchats
    const UserSearchScreen(),    // Tab 2: User-Suche / Kontakte
  ];

  // Titel für die AppBar, passend zum aktuellen Tab (optional, wenn jeder Screen seine eigene AppBar hat)
  // final List<String> _appBarTitles = [
  //   "Chats",
  //   "Groups",
  //   "Search Users",
  // ];

  @override
  void initState() {
    super.initState();
    AppLogger.debug("ChatMainTabsScreen: initState");
  }

  @override
  void dispose() {
    _pageController.dispose();
    AppLogger.debug("ChatMainTabsScreen: dispose");
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    // Wenn der PageController verwendet wird, um die Seite zu wechseln,
    // wird _onPageChanged automatisch aufgerufen und setzt _currentIndex.
    // Ein direkter setState hier ist nicht unbedingt nötig, wenn _pageController.jumpToPage
    // oder animateToPage den onPageChanged Callback auslöst.
    // Aber es schadet auch nicht, es explizit zu setzen.
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug("ChatMainTabsScreen: Building with currentIndex: $_currentIndex");
    final theme = Theme.of(context);

    return Scaffold(
      // In diesem Aufbau hat jeder Tab-Screen (ChatHomeScreen, GroupChatListScreen etc.)
      // seine eigene AppBar. Das gibt mehr Flexibilität für tab-spezifische Aktionen.
      // Wenn du eine globale AppBar für alle Chat-Tabs möchtest, die sich nur im Titel ändert,
      // könntest du sie hier definieren:
      // appBar: AppBar(
      //   title: Text(_appBarTitles[_currentIndex], style: TextStyle(color: Colors.white)),
      //   backgroundColor: const Color(0xff040324),
      //   elevation: 0,
      // ),
      backgroundColor: const Color(0xff040324), // Hintergrund für den PageView-Bereich
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged, // Aktualisiert _currentIndex beim Wischen
        children: _screens,
        physics: const NeverScrollableScrollPhysics(), // Deaktiviert das Wischen, wenn nur über Tabs navigiert werden soll
        // Entferne dies, wenn Wischen erwünscht ist.
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped, // Wechselt die Seite und aktualisiert _currentIndex
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? const Color(0xff0a0930), // Dunklerer Ton für die Bar
        indicatorColor: theme.colorScheme.primary.withOpacity(0.2), // Farbe des Indikators unter dem Icon
        height: 65, // Etwas mehr Höhe für die Bar
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // Oder .onlyShowSelected
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          NavigationDestination(
            icon: Icon(Iconsax.message, color: _currentIndex == 0 ? theme.colorScheme.primary : Colors.grey[500]),
            selectedIcon: Icon(Iconsax.message5, color: theme.colorScheme.primary),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.messages_1, color: _currentIndex == 1 ? theme.colorScheme.primary : Colors.grey[500]),
            selectedIcon: Icon(Iconsax.messages_15, color: theme.colorScheme.primary),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.search_normal_1, color: _currentIndex == 2 ? theme.colorScheme.primary : Colors.grey[500]),
            selectedIcon: Icon(Iconsax.search_normal_1, color: theme.colorScheme.primary), // Gleiches Icon, aber Farbe ändert sich
            label: 'Search',
          ),
        ],
        // Theming für die Labels (optional)
        // labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
        //   (Set<MaterialState> states) {
        //     if (states.contains(MaterialState.selected)) {
        //       return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary);
        //     }
        //     return TextStyle(fontSize: 12, color: Colors.grey[500]);
        //   },
        // ),
      ),
    );
  }
}