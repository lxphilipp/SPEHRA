import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/domain/entities/user_profile_entity.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';

/// A custom app bar for the main screens of the application.
///
/// It can display a title or the user's stats.
class CustomMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title of the app bar.
  final String? title;

  /// The actions of the app bar.
  final List<Widget>? actions;

  /// Creates a [CustomMainAppBar].
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
            const _AppBarUserStats(), // Show user stats by default
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

/// A private widget that displays the user's stats in the app bar.
class _AppBarUserStats extends StatelessWidget {
  /// Creates an [_AppBarUserStats] widget.
  const _AppBarUserStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<UserProfileProvider>();
    final UserProfileEntity? userProfile = profileProvider.userProfile;

    if (profileProvider.isLoadingProfile && userProfile == null) {
      return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (userProfile != null) {
      String imagePath = 'assets/icons/Level_Icons/1. Beginner.png';
      switch (userProfile.level) {
        case 1:
          imagePath = 'assets/icons/Level_Icons/1. Beginner.png';
          break;
        case 2:
          imagePath = 'assets/icons/Level_Icons/2. Intermediate.png';
          break;
        case 3:
          imagePath = 'assets/icons/Level_Icons/3. Advanced.png';
          break;
        case 4:
          imagePath = 'assets/icons/Level_Icons/4. Professional.png';
          break;
        case 5:
          imagePath = 'assets/icons/Level_Icons/5. Master.png';
          break;
        case 6:
          imagePath = 'assets/icons/Level_Icons/possible_intensification.png';
          break;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: kToolbarHeight - 36.0, child: Image.asset(imagePath)),
          Text(
            'Pts: ${userProfile.points} | Lvl: ${userProfile.level}',
            style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10, color: theme.colorScheme.onSurface),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
