import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class TransportPageContent extends StatelessWidget {
  const TransportPageContent({super.key});

  Widget _buildOptionButton(BuildContext context, String label) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context); // Theme holen

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () => provider.nextPage(context),
      child: Text(label, style: const TextStyle(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
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
                child: Text('skip', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                textAlign: TextAlign.center, // Bessere Zentrierung
                text: TextSpan(
                  style: theme.textTheme.headlineSmall,
                  children: <TextSpan>[
                    const TextSpan(text: 'What is your go to '),
                    TextSpan(
                      text: 'method of transport',
                      style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: '?'),
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
              _buildOptionButton(context, 'Car'),
              _buildOptionButton(context, 'Public Transport'),
              _buildOptionButton(context, 'By foot'),
              _buildOptionButton(context, 'Airplane'),
            ],
          ),
        ),
      ],
    );
  }
}