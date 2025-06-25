import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../domain/entities/intro_page_entity.dart';
import '../../domain/usecases/get_intro_pages_usecase.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart'; // Pfad zum finalen Screen anpassen

class IntroductionProvider with ChangeNotifier {
  final GetIntroPagesUseCase _getIntroPagesUseCase;

  IntroductionProvider({required GetIntroPagesUseCase getIntroPagesUseCase})
      : _getIntroPagesUseCase = getIntroPagesUseCase {
    loadPages();
  }

  List<IntroPageEntity> _pages = [];
  bool _isLoading = true;
  PageController pageController = PageController();

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
    if (pageController.page!.round() < _pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen())
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}