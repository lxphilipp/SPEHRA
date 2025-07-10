import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/challenge_provider.dart';

class Step2DescriptionPage extends StatelessWidget {
  const Step2DescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChallengeProvider>();
    final description = context.select((ChallengeProvider p) => p.challengeInProgress?.description);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Super! Beschreibe nun deine Challenge.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Was ist das Ziel? Warum ist diese Aktion wichtig?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextFormField(
            initialValue: description,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              hintText: 'z.B. "Befreien wir unseren Park von Müll..."',
            ),
            maxLines: 5,
            minLines: 3,
            onChanged: (value) {
              provider.updateChallengeInProgress(description: value);
            },
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}