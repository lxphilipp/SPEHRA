import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class IntroductionPageContent extends StatelessWidget {
  const IntroductionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.headlineMedium,
                    children: <TextSpan>[
                      const TextSpan(text: 'Hi,\nmy name is '),
                      TextSpan(
                        text: 'Sphera',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(
                          text: ',\nI will try to help you reach\nyour sustainability goals.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: TextButton(
            onPressed: () => provider.nextPage(context),
            child: Text(
              'Continue',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'OswaldRegular',
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}