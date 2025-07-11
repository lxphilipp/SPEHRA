import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/challenge_provider.dart';
import '../llm_feedback_widget.dart'; // Import des neuen Widgets

class Step3CategoriesPage extends StatefulWidget {
  const Step3CategoriesPage({super.key});

  @override
  State<Step3CategoriesPage> createState() => _Step3CategoriesPageState();
}

class _Step3CategoriesPageState extends State<Step3CategoriesPage> {
  final List<String> _categoryKeys = List.generate(17, (i) => 'goal${i + 1}');
  final List<String> _categoryImagePaths = List.generate(17, (i) => 'assets/icons/17_SDG_Icons/${i + 1}.png');

  void _onCategoryTapped(List<String> selectedCategories, String key) {
    final provider = context.read<ChallengeProvider>();
    final newSelection = List<String>.from(selectedCategories);
    if (newSelection.contains(key)) {
      newSelection.remove(key);
    } else {
      newSelection.add(key);
    }
    // Provider updaten UND Feedback anfordern
    provider.updateChallengeInProgress(categories: newSelection);
    provider.requestLlmFeedback('categories');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final selectedCategories = provider.challengeInProgress?.categories ?? [];
    final feedbackData = provider.llmFeedbackData['categories'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Wähle passende SDG-Kategorien aus.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Welche globalen Ziele unterstützt deine Challenge?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: List.generate(_categoryKeys.length, (index) {
                  final key = _categoryKeys[index];
                  final imagePath = _categoryImagePaths[index];
                  final isSelected = selectedCategories.contains(key);

                  return GestureDetector(
                    onTap: () => _onCategoryTapped(selectedCategories, key),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(imagePath, fit: BoxFit.contain),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // NEU: Feedback-Widget
          LlmFeedbackWidget(
            isLoading: provider.isFetchingFeedback,
            error: provider.feedbackError,
            feedback: feedbackData?['main_feedback'],
            improvementSuggestion: feedbackData?['improvement_suggestion'],
            onRetry: () => provider.requestLlmFeedback('categories'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}