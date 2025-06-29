import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class DietPageContent extends StatelessWidget {
  const DietPageContent({super.key});

  Widget _buildOptionButton(BuildContext context, String label) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () {
        provider.nextPage(context);
      },
      // OPTIMIERT: Die Textfarbe wird vom Button-Theme geerbt.
      child: Text(label, style: const TextStyle(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    // OPTIMIERT: Holen des Themes für den Zugriff auf Farben und Stile
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => provider.nextPage(context),
                // OPTIMIERT: Die Textfarbe wird vom TextButtonTheme geerbt,
                // kann aber für eine Akzentuierung überschrieben werden.
                child: Text('skip', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineSmall,
                  children: <TextSpan>[
                    const TextSpan(text: ' What does your '),
                    TextSpan(
                      text: 'diet',
                      // OPTIMIERT: Die Akzentfarbe kommt aus dem ColorScheme
                      style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: ' look\n like ?'),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, left: 20, right: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildOptionButton(context, 'Vegan'),
              _buildOptionButton(context, 'Vegetarian'),
              _buildOptionButton(context, 'Pescatarian'),
              _buildOptionButton(context, 'Omnivore'),
            ],
          ),
        ),
      ],
    );
  }
}