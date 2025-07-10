import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/challenge_provider.dart';

class Step1TitlePage extends StatelessWidget {
  const Step1TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChallengeProvider>();
    final title = context.select((ChallengeProvider p) => p.challengeInProgress?.title);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zuerst: Welchen Titel soll deine Challenge haben?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Ein guter Titel ist kurz, klar und motivierend.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextFormField(
            initialValue: title,
            decoration: const InputDecoration(
              labelText: 'Challenge-Titel',
              hintText: 'z.B. "Müll sammeln im Stadtpark"',
            ),
            onChanged: (value) {
              // Aktualisiert den Titel im Provider bei jeder Eingabe
              provider.updateChallengeInProgress(title: value);
            },
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}