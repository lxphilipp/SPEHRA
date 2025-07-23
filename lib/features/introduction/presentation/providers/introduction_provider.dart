import 'package:flutter/material.dart';
// Import the main app layout, not just one of its screens.
import '../../../../core/layouts/responsive_main_navigation.dart';
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
    // Check if the page controller is attached to a view.
    if (!pageController.hasClients) return;

    if (pageController.page!.round() < _pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // CORRECTED: Navigate to the main responsive layout, not the HomeScreen directly.
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