import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/layouts/responsive_main_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../domain/entities/intro_page_entity.dart';
import '../../domain/usecases/get_intro_pages_usecase.dart';

/// Manages the state for the introduction feature.
///
/// This provider handles loading introduction pages, navigating between them,
/// and marking the introduction as completed.
class IntroductionProvider with ChangeNotifier {
  final GetIntroPagesUseCase _getIntroPagesUseCase;

  /// Creates an [IntroductionProvider].
  ///
  /// Requires a [GetIntroPagesUseCase] to fetch introduction pages.
  /// Calls [loadPages] upon initialization.
  IntroductionProvider({required GetIntroPagesUseCase getIntroPagesUseCase})
      : _getIntroPagesUseCase = getIntroPagesUseCase {
    loadPages();
  }

  /// The list of introduction pages.
  List<IntroPageEntity> _pages = [];

  /// Indicates whether the introduction pages are currently being loaded.
  bool _isLoading = true;

  /// Controls the [PageView] used to display introduction pages.
  final PageController pageController = PageController();

  /// Gets the list of introduction pages.
  List<IntroPageEntity> get pages => _pages;

  /// Gets whether the introduction pages are currently being loaded.
  bool get isLoading => _isLoading;

  /// Loads the introduction pages.
  ///
  /// Sets [_isLoading] to true, fetches the pages using [_getIntroPagesUseCase],
  /// then sets [_isLoading] to false and notifies listeners.
  Future<void> loadPages() async {
    _isLoading = true;
    notifyListeners();
    _pages = await _getIntroPagesUseCase();
    _isLoading = false;
    notifyListeners();
  }

  /// Navigates to the next introduction page or completes the introduction.
  ///
  /// If there are more pages, it animates to the next page.
  /// Otherwise, it marks the introduction as completed for the logged-in user
  /// (if their profile exists) and navigates to the main app.
  void nextPage(BuildContext context) {
    if (!pageController.hasClients) return;

    if (pageController.page!.round() < _pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Wenn die Einführung beendet ist:
      final profileProvider = context.read<UserProfileProvider>();
      final authProvider = context.read<AuthenticationProvider>();

      if (authProvider.isLoggedIn) {
        final profile = profileProvider.userProfile;
        if (profile != null) {
          profileProvider.updateProfile(
            name: profile.name,
            age: profile.age,
            studyField: profile.studyField,
            school: profile.school,
            hasCompletedIntro: true,
          );
        }
      }

      // 2. Navigiere zur Haupt-App
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResponsiveMainNavigation())
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
