import 'package:flutter/material.dart';
import '../widgets/home_content.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int pageIndex, {int? challengeTabIndex}) navigateToPage;

  const HomeScreen({
    super.key,
    required this.navigateToPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pass the function down to the content widget.
        body: HomeContent(navigateToPage: navigateToPage)
    );
  }
}
