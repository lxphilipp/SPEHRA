import 'package:flutter/material.dart';
import 'package:flutter_sdg/core/widgets/background_image.dart';

class IntroLayout extends StatelessWidget {
  final Widget body;

  const IntroLayout({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: body,
          ),
        ],
      ),
    );
  }
}
