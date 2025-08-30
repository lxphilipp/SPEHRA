import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../sdg/presentation/providers/sdg_list_provider.dart';
import '../../../presentation/providers/challenge_provider.dart';
import '../llm_feedback_widget.dart';
import '../../../../sdg/presentation/providers/sdg_detail_provider.dart';

class Step3CategoriesPage extends StatefulWidget {
  const Step3CategoriesPage({super.key});

  @override
  State<Step3CategoriesPage> createState() => _Step3CategoriesPageState();
}

class _Step3CategoriesPageState extends State<Step3CategoriesPage> {
  void _onCategoryToggled(String key) {
    // Read the provider fresh inside the method to get the latest state.
    final challengeProvider = context.read<ChallengeProvider>();

    // Get the most current list of categories directly from the provider's state.
    final currentSelection = challengeProvider.challengeInProgress?.categories ?? [];

    // Create a mutable copy to modify it.
    final newSelection = List<String>.from(currentSelection);

    // Toggle the selection.
    if (newSelection.contains(key)) {
      newSelection.remove(key);
    } else {
      newSelection.add(key);
    }

    // Now, update the provider and request feedback with the guaranteed fresh list.
    challengeProvider.updateChallengeInProgress(categories: newSelection);
    challengeProvider.requestLlmFeedback('categories');
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final sdgListProvider = context.watch<SdgListProvider>();
    final sdgDetailProvider = context.read<SdgDetailProvider>();

    final selectedCategories = challengeProvider.challengeInProgress?.categories ?? [];
    final allSdgItems = sdgListProvider.sdgListItems;
    final feedbackData = challengeProvider.llmFeedbackData['categories'];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Choose suitable SDG categories.',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a category and expand for details.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: allSdgItems.length,
            itemBuilder: (context, index) {
              final sdgItem = allSdgItems[index];
              final isSelected = selectedCategories.contains(sdgItem.id);

              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  shape: const Border(),
                  key: PageStorageKey(sdgItem.id),
                  onExpansionChanged: (isExpanding) {
                    if (isExpanding) {
                      sdgDetailProvider.fetchSdgDetails(sdgItem.id);
                    }
                  },
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          _onCategoryToggled(sdgItem.id);
                        },
                      ),
                      const SizedBox(width: 8),
                      Image.asset(sdgItem.listImageAssetPath, width: 40, height: 40),
                    ],
                  ),
                  title: Text(sdgItem.title, style: theme.textTheme.titleMedium),
                  children: <Widget>[
                    Consumer<SdgDetailProvider>(
                      builder: (context, detailProvider, child) {
                        if (detailProvider.isLoading && detailProvider.currentSdgDetail?.id != sdgItem.id) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final sdgDetails = detailProvider.currentSdgDetail;
                        if (sdgDetails == null || sdgDetails.id != sdgItem.id) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          color: theme.colorScheme.surfaceContainer,
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sdgDetails.descriptionPoints
                                .map((point) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("• ", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
                                ],
                              ),
                            ))
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: LlmFeedbackWidget(
            isLoading: challengeProvider.isFetchingFeedback,
            error: challengeProvider.feedbackError,
            feedback: feedbackData?['main_feedback'],
            improvementSuggestion: feedbackData?['improvement_suggestion'],
            onRetry: () => challengeProvider.requestLlmFeedback('categories'),
          ),
        ),
      ],
    );
  }
}