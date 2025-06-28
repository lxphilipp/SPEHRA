import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/home/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/domain/entities/user_profile_entity.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';

class CustomMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CustomMainAppBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          const Spacer(),
          if (title != null)
            Text(title!, style: theme.appBarTheme.titleTextStyle)
          else
            const _AppBarUserStats(), // Standardmäßig User-Stats anzeigen
          const Spacer(),
        ],
      ),
      actions: actions,
      backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// Private Hilfs-Widgets, direkt aus deinem alten Layout übernommen
class _AppBarLogo extends StatelessWidget {
  const _AppBarLogo();

  @override
  Widget build(BuildContext context) {
    double logoHeight = kToolbarHeight - 20.0;
    return InkWell(
      onTap: () {
        // Diese Logik ist vielleicht nicht mehr nötig, da der Home-Screen
        // immer im IndexedStack geladen bleibt. Ein Tap hier könnte
        // einfach zum Home-Tab wechseln, was aber über die NavigationBar passiert.
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset('assets/logo/Logo-Bild.png', height: logoHeight),
      ),
    );
  }
}

class _AppBarUserStats extends StatelessWidget {
  const _AppBarUserStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<UserProfileProvider>();
    final UserProfileEntity? userProfile = profileProvider.userProfile;

    if (profileProvider.isLoadingProfile && userProfile == null) {
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (userProfile != null) {
      String imagePath = 'assets/icons/Level_Icons/1. Beginner.png';
      switch (userProfile.level) {
        case 1: imagePath = 'assets/icons/Level_Icons/1. Beginner.png'; break;
        case 2: imagePath = 'assets/icons/Level_Icons/2. Intermediate.png'; break;
        case 3: imagePath = 'assets/icons/Level_Icons/3. Advanced.png'; break;
        case 4: imagePath = 'assets/icons/Level_Icons/4. Professional.png'; break;
        case 5: imagePath = 'assets/icons/Level_Icons/5. Master.png'; break;
        case 6: imagePath = 'assets/icons/Level_Icons/possible_intensification.png'; break;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: kToolbarHeight - 36.0, child: Image.asset(imagePath)),
          Text(
            'Pts: ${userProfile.points} | Lvl: ${userProfile.level}',
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: AppColors.primaryText),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}