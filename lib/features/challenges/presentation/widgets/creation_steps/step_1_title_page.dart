import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/challenge_provider.dart';
import '../llm_feedback_widget.dart'; // Import des neuen Widgets

class Step1TitlePage extends StatefulWidget {
  const Step1TitlePage({super.key});

  @override
  State<Step1TitlePage> createState() => _Step1TitlePageState();
}

class _Step1TitlePageState extends State<Step1TitlePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialTitle = context.read<ChallengeProvider>().challengeInProgress?.title ?? '';
    _controller = TextEditingController(text: initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChallengeProvider>();
    // Wir verwenden `context.watch` hier, damit das Widget neu gebaut wird, wenn sich das Feedback ändert.
    final feedbackData = context.watch<ChallengeProvider>().llmFeedbackData['title'];

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
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Challenge-Titel',
              hintText: 'z.B. "Müll sammeln im Stadtpark"',
            ),
            onChanged: (value) {
              provider.updateChallengeInProgress(title: value);
              if (value.trim().isNotEmpty) {
                provider.requestLlmFeedback('title');
              }
            },
            textCapitalization: TextCapitalization.sentences,
          ),
          LlmFeedbackWidget(
            isLoading: context.watch<ChallengeProvider>().isFetchingFeedback,
            error: context.watch<ChallengeProvider>().feedbackError,
            feedback: feedbackData?['main_feedback'],
            improvementSuggestion: feedbackData?['improvement_suggestion'],
            onRetry: () => provider.requestLlmFeedback('title'),
          ),
        ],
      ),
    );
  }
}