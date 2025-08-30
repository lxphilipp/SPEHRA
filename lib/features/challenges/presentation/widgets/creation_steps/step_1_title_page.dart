import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/challenge_provider.dart';
import '../llm_feedback_widget.dart';

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
    final feedbackData = context.watch<ChallengeProvider>().llmFeedbackData['title'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First: What title should your challenge have?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'A good title is short, clear, and motivating.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Challenge Title',
              hintText: 'e.g. "Collecting trash in the city park"',
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