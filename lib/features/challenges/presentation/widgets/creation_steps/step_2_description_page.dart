import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/challenge_provider.dart';
import '../llm_feedback_widget.dart'; // Import des neuen Widgets

class Step2DescriptionPage extends StatefulWidget {
  const Step2DescriptionPage({super.key});

  @override
  State<Step2DescriptionPage> createState() => _Step2DescriptionPageState();
}

class _Step2DescriptionPageState extends State<Step2DescriptionPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialDescription = context.read<ChallengeProvider>().challengeInProgress?.description ?? '';
    _controller = TextEditingController(text: initialDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChallengeProvider>();
    final feedbackData = context.watch<ChallengeProvider>().llmFeedbackData['description'];

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
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              hintText: 'z.B. "Befreien wir unseren Park von Müll..."',
            ),
            maxLines: 5,
            minLines: 1,
            onChanged: (value) {
              provider.updateChallengeInProgress(description: value);
              if (value.trim().length > 20) {
                provider.requestLlmFeedback('description');
              }
            },
            textCapitalization: TextCapitalization.sentences,
          ),
          LlmFeedbackWidget(
            isLoading: context.watch<ChallengeProvider>().isFetchingFeedback,
            error: context.watch<ChallengeProvider>().feedbackError,
            feedback: feedbackData?['main_feedback'],
            improvementSuggestion: feedbackData?['improvement_suggestion'],
            onRetry: () => provider.requestLlmFeedback('description'),
          ),
        ],
      ),
    );
  }
}