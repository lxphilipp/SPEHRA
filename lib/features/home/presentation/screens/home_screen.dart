import 'package:flutter/material.dart';
import 'package:flutter_sdg/core/layouts/responsive_main_navigation.dart';
import 'package:flutter_sdg/core/widgets/custom_main_app_bar.dart';
import '../widgets/home_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: HomeContent()
    );
  }
}
