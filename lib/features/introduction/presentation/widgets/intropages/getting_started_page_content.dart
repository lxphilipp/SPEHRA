import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class GettingStartedPageContent extends StatelessWidget {
  const GettingStartedPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    // OPTIMIERT: Holen des Themes für den Zugriff auf Farben und Stile
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            textAlign: TextAlign.center, // Sorgt für eine schönere Darstellung
            text: TextSpan(
              // OPTIMIERT: Der Standardstil kommt aus dem Theme
              style: theme.textTheme.headlineSmall,
              children: <TextSpan>[
                const TextSpan(text: 'Would you mind\n'),
                TextSpan(
                  text: 'answering a few questions\n',
                  // OPTIMIERT: Die Akzentfarbe kommt aus dem ColorScheme
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic),
                ),
                const TextSpan(
                    text: 'so we can provide you\nthe best goal compatibility?'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.nextPage(context),
            child: Text(
              'Let\'s get started',
              // OPTIMIERT: Der Stil wird vom Theme abgeleitet
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