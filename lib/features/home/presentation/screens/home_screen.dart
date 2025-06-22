import 'package:flutter/material.dart';
import 'package:flutter_sdg/core/layouts/main_app_layout.dart';
import '../widgets/home_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainAppLayout(body: HomeContent());
  }
}
