import 'package:flutter/material.dart';
import '../../domain/entities/intro_page_entity.dart';

class IntroCardWidget extends StatelessWidget {
  final IntroPageEntity pageData;
  const IntroCardWidget({super.key, required this.pageData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color gradientColor = theme.colorScheme.primaryContainer;

    final TextStyle textStyle = theme.textTheme.bodyLarge!.copyWith(
      fontFamily: 'OswaldLight',
      color: theme.colorScheme.onPrimaryContainer,
      decoration: TextDecoration.none,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            gradientColor,
            gradientColor,
            gradientColor.withOpacity(0.0)
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pageData.title != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(pageData.title!,
                  style: textStyle.copyWith(fontSize: 21)),
            ),
          if (pageData.description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(pageData.description!,
                  style: textStyle.copyWith(fontSize: 19)),
            ),
          const Spacer(),
          if (pageData.ctaText != null)
            Center(
              child: Text(pageData.ctaText!,
                  style: textStyle.copyWith(fontSize: 30)),
            ),
        ],
      ),
    );
  }
}