import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class EnergyPageContent extends StatelessWidget {
  const EnergyPageContent({super.key});

  Widget _buildOptionButton(BuildContext context, String label) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context); // Theme holen

    return OutlinedButton(
      // OPTIMIERT: Stil wird vom Theme abgeleitet
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () => provider.nextPage(context),
      child: Text(label, style: const TextStyle(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context); // Theme holen

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => provider.nextPage(context),
                // OPTIMIERT: Farbe aus dem Theme
                child: Text('skip', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                textAlign: TextAlign.center, // Bessere Zentrierung für den Text
                text: TextSpan(
                  // OPTIMIERT: Basis-Stil aus dem Theme
                  style: theme.textTheme.headlineSmall,
                  children: <TextSpan>[
                    const TextSpan(text: 'What '),
                    TextSpan(
                      text: 'kind of energy',
                      // OPTIMIERT: Akzentfarbe aus dem Theme
                      style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: ' do you use in your household?'),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, left: 20, right: 20),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildOptionButton(context, 'Gas'),
              _buildOptionButton(context, 'Oil'),
              _buildOptionButton(context, 'Renewables'),
              _buildOptionButton(context, 'A Mix of Them'),
            ],
          ),
        ),
      ],
    );
  }
}