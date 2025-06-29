import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class IntroductionPageContent extends StatelessWidget {
  const IntroductionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context); // Theme für den Zugriff auf Stile holen

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              // OPTIMIERT: Basis-Stil aus dem Theme
              style: theme.textTheme.headlineMedium,
              children: <TextSpan>[
                const TextSpan(text: 'Hi,\nmy name is '),
                TextSpan(
                  text: 'Sphera',
                  // OPTIMIERT: Akzentfarbe aus dem ColorScheme
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic),
                ),
                const TextSpan(
                    text: ',\nI will try to help you reach\nyour sustainability goals.'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.nextPage(context),
            child: Text(
              'Continue',
              // OPTIMIERT: Stil aus dem Theme ableiten
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'OswaldRegular',
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}