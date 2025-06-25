import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/chat_main_tabs_screen.dart';
import 'package:provider/provider.dart';

// Core Widgets
import '/core/widgets/menuDrawer_layout.dart';
import '/core/theme/app_colors.dart'; // Für Fallback-Farben, falls Theme nicht alles abdeckt

// Feature Provider
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '/features/profile/domain/entities/user_profile_entity.dart'; // Für Typisierung

// Screens für die Navigation im Drawer (Pfade anpassen!)
import '/features/home/presentation/screens/home_screen.dart';
import '/features/challenges/presentation/screens/challenge_list_screen.dart';
import '/features/challenges/presentation/screens/create_challenge_screen.dart';
import '/features/profile/presentation/screens/edit_profile_screen.dart';
import '/features/profile/presentation/screens/profile_stats_screen.dart';
import '/features/sdg/presentation/screens/sdg_list_screen.dart';

class MainAppLayout extends StatelessWidget {
  final Widget body;
  final String? appBarTitleText;
  final bool showUserStatsInAppBar;
  final List<Widget>? appBarActions; // Für zusätzliche, screen-spezifische Aktionen

  const MainAppLayout({
    super.key,
    required this.body,
    this.appBarTitleText,
    this.showUserStatsInAppBar = true,
    this.appBarActions,
  });

  List<DrawerItem> _buildMenuItems(BuildContext context) {
    // Hilfsfunktion für die Navigation, um den Drawer nach dem Klick zu schließen
    void navigateAndCloseDrawer(Widget page) {
      Navigator.pop(context); // Schließt den Drawer
      // Verwende pushReplacement, wenn du nicht zum Drawer zurückkehren willst
      // oder push, wenn du zurückkehren können möchtest.
      // Für Hauptnavigation ist pushReplacement oft gut, um den Stack sauber zu halten.
      // Wenn der Screen schon im Stack ist, kann man auch nur popUntil oder ähnliches verwenden.
      // Für Einfachheit hier erstmal push.
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
    void navigateAndReplace(Widget page) {
      Navigator.pop(context); // Schließt den Drawer
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    }


    return [
      ExpansionDrawerItem(
        title: 'Home & Challenges',
        icon: Icons.explore_outlined,
        children: [
          SingleDrawerItem(
            title: 'Dashboard', // Früher "Homepage"
            icon: Icons.home_outlined, // Passenderes Icon
            onTap: () => navigateAndReplace(const HomeScreen()),
          ),
          SingleDrawerItem(
            title: 'All Challenges', // Früher "Challenges"
            icon: Icons.emoji_events_outlined, // Passenderes Icon
            onTap: () => navigateAndCloseDrawer(const ChallengeListScreen()),
          ),
          SingleDrawerItem(
            title: 'Create Challenge',
            icon: Icons.add_circle_outline,
            onTap: () => navigateAndCloseDrawer(const CreateChallengeScreen()),
          ),
        ],
      ),
      ExpansionDrawerItem(
        title: 'My Profile', // Umbenannt von "Profile"
        icon: Icons.person_outline_rounded,
        children: [
          SingleDrawerItem(
            title: 'View Profile & Stats', // Früher "My Profile"
            icon: Icons.account_circle_outlined,
            onTap: () => navigateAndCloseDrawer(const ProfileStatsScreen()),
          ),
          SingleDrawerItem(
            title: 'Edit Profile',
            icon: Icons.edit_outlined,
            onTap: () => navigateAndCloseDrawer(const EditProfileScreen()),
          ),
          SingleDrawerItem(
            title: 'Chat', // Annahme: Chat wird noch refactored
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => navigateAndCloseDrawer(const ChatMainTabsScreen()),
          ),
        ],
      ),
      ExpansionDrawerItem(
        title: 'Discover & Learn', // Umbenannt von "Infos"
        icon: Icons.lightbulb_outline_rounded,
        children: [
          SingleDrawerItem(
            title: 'The 17 SDGs',
            icon: Icons.eco_outlined,
            onTap: () => navigateAndCloseDrawer(const SdgListScreen()),
          ),
        ],
      ),
      // Beispiel für einen direkten Link ohne ExpansionTile
      // SingleDrawerItem(
      //   title: "Settings",
      //   icon: Icons.settings_outlined,
      //   onTap: () { /* Navigate to Settings */ Navigator.pop(context); },
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true, // Behalte dies bei, wenn dein Design es erfordert (transparente AppBar)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0, // Wichtig für das Row-Layout im title
        title: Row(
          children: [
            const _AppBarLogo(), // Logo links
            const Spacer(), // Nimmt den mittleren Platz ein
            if (showUserStatsInAppBar)
              const _AppBarUserStats() // User-Stats rechts von der Mitte
            else if (appBarTitleText != null)
              Expanded( // Nimmt verfügbaren Platz, wenn keine Stats da sind
                child: Text(
                  appBarTitleText!,
                  style: theme.appBarTheme.titleTextStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (showUserStatsInAppBar || appBarTitleText != null) const Spacer(), // Balance zum Logo
          ],
        ),
        actions: [
          if (appBarActions != null) ...appBarActions!,
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu_rounded, color: theme.appBarTheme.iconTheme?.color ?? AppColors.accentGreen),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
          const SizedBox(width: 8), // Kleiner Abstand zum Rand
        ],
        backgroundColor: Colors.transparent, // Für extendBodyBehindAppBar
        elevation: 0, // Keine Schatten für transparente AppBar
      ),
      body: body,
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // Etwas breiter für bessere Lesbarkeit
        child: MenuDrawerWidget(
          menuItems: _buildMenuItems(context),
          onItemTap: () {
            // Der Drawer wird bereits durch die onTap-Handler der SingleDrawerItems geschlossen.
            // Diese zusätzliche onItemTap-Logik im MenuDrawerWidget selbst ist optional,
            // falls man nach JEDEM Tap im Drawer eine Aktion ausführen will (z.B. Analytics).
            // Für das reine Schließen ist es hier nicht mehr zwingend nötig, wenn die Items es tun.
          },
        ),
      ),
    );
  }
}

// --- Private Hilfs-Widgets für die AppBar ---

class _AppBarLogo extends StatelessWidget {
  const _AppBarLogo();

  // Innerhalb der Klasse _AppBarLogo

  @override
  Widget build(BuildContext context) {
    double logoHeight = kToolbarHeight - 20.0;

    return InkWell(
      onTap: () {
        final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);
        bool isAlreadyHome = false;
        if (currentRoute is MaterialPageRoute) { // Oder CupertinoPageRoute etc.
          if (currentRoute.settings.name == '/' || currentRoute.settings.name == null && Navigator.of(context).canPop() == false) {
            if (!Navigator.of(context).canPop()) {
              isAlreadyHome = true;
            }
          }
        }


        if (!isAlreadyHome) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: Image.asset(
          'assets/logo/Logo-Bild.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _AppBarUserStats extends StatelessWidget {
  const _AppBarUserStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = Provider.of<UserProfileProvider>(context); // listen: true
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false); // listen: false, nur für isLoggedIn

    final UserProfileEntity? userProfile = profileProvider.userProfile;
    double iconHeight = kToolbarHeight - 36.0;

    if (!authProvider.isLoggedIn) {
      return const SizedBox.shrink();
    }

    if (profileProvider.isLoadingProfile && userProfile == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: (kToolbarHeight - 20)/2 ), // Zentrieren
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryText,)),
      );
    }

    if (userProfile != null) {
      String imagePath = 'assets/icons/Level_Icons/1. Beginner.png'; // Fallback
      switch (userProfile.level) {
        case 1: imagePath = 'assets/icons/Level_Icons/1. Beginner.png'; break;
        case 2: imagePath = 'assets/icons/Level_Icons/2. Intermediate.png'; break;
        case 3: imagePath = 'assets/icons/Level_Icons/3. Advanced.png'; break;
        case 4: imagePath = 'assets/icons/Level_Icons/4. Professional.png'; break;
        case 5: imagePath = 'assets/icons/Level_Icons/5. Master.png'; break;
        case 6: imagePath = 'assets/icons/Level_Icons/possible_intensification.png'; break;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath.isNotEmpty)
              SizedBox(
                height: iconHeight,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            if (imagePath.isNotEmpty) const SizedBox(height: 1),
            Text(
              'Pts: ${userProfile.points} | Lvl: ${userProfile.level}',
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primaryText, fontSize: 10), // Kleinere Schrift
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    // Fallback, wenn Profil geladen wird oder ein Fehler auftrat, aber User eingeloggt ist
    return Text("...", style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primaryText));
  }
}