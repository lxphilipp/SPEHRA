import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class SDGPageContent extends StatelessWidget {
  const SDGPageContent({super.key});

  Widget _buildOptionButton(BuildContext context, String label) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context); // Theme holen

    return OutlinedButton(
      // OPTIMIERT: Stil wird vom Theme abgeleitet
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () => provider.nextPage(context),
      child: Text(label, style: const TextStyle(fontSize: 20)),
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
                textAlign: TextAlign.center, // Bessere Zentrierung
                text: TextSpan(
                  // OPTIMIERT: Basis-Stil aus dem Theme
                  style: theme.textTheme.headlineSmall,
                  children: <TextSpan>[
                    const TextSpan(text: "How much do you know about the UN's "),
                    TextSpan(
                      text: 'Sustainability Development Goals',
                      // OPTIMIERT: Akzentfarbe aus dem Theme
                      style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: ' (SDGs)?'),
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
              _buildOptionButton(context, 'Never heard of them'),
              _buildOptionButton(context, 'hardly anything'),
              _buildOptionButton(context, 'a little'),
              _buildOptionButton(context, 'quite a bit'),
              _buildOptionButton(context, "I'm an expert"),
            ],
          ),
        ),
      ],
    );
  }
}