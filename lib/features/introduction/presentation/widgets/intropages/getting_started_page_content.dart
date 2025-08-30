import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class GettingStartedPageContent extends StatelessWidget {
  const GettingStartedPageContent({super.key});

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
                    style: theme.textTheme.headlineSmall,
                    children: <TextSpan>[
                      const TextSpan(text: 'Would you mind\n'),
                      TextSpan(
                        text: 'answering a few questions\n',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(
                          text: 'so we can provide you\nthe best goal compatibility?'),
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
              'Let\'s get started',
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