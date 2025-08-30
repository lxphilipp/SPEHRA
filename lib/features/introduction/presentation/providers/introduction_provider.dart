import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/layouts/responsive_main_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../domain/entities/intro_page_entity.dart';
import '../../domain/usecases/get_intro_pages_usecase.dart';

class IntroductionProvider with ChangeNotifier {
  final GetIntroPagesUseCase _getIntroPagesUseCase;

  IntroductionProvider({required GetIntroPagesUseCase getIntroPagesUseCase})
      : _getIntroPagesUseCase = getIntroPagesUseCase {
    loadPages();
  }

  List<IntroPageEntity> _pages = [];
  bool _isLoading = true;
  final PageController pageController = PageController();

  List<IntroPageEntity> get pages => _pages;
  bool get isLoading => _isLoading;

  Future<void> loadPages() async {
    _isLoading = true;
    notifyListeners();
    _pages = await _getIntroPagesUseCase();
    _isLoading = false;
    notifyListeners();
  }

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