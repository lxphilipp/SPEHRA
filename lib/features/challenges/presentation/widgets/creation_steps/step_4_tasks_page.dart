import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/challenges/presentation/widgets/creation_steps/task_selection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../domain/entities/trackable_task.dart';
import '../../../presentation/providers/challenge_provider.dart';
import '../llm_feedback_widget.dart';

class Step4TasksPage extends StatelessWidget {
  const Step4TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final challenge = provider.challengeInProgress;
    final tasks = challenge?.tasks ?? [];
    final feedbackData = provider.llmFeedbackData['tasks'];

    // Helper to get the correct icon for each task type
    IconData getIconForTask(TrackableTask task) {
      if (task is CheckboxTask) return Iconsax.task_square;
      if (task is StepCounterTask) return Iconsax.ruler;
      if (task is LocationVisitTask) return Iconsax.location;
      if (task is ImageUploadTask) return Iconsax.camera;
      return Iconsax.task;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Now add the tasks.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'A good challenge has at least one verifiable task (e.g., photo upload or location visit).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Button to add a new task
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Iconsax.add),
              label: const Text('Add Task'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => TaskSelectionDialog(
                    challengeProvider: provider,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          LlmFeedbackWidget(
            isLoading: provider.isFetchingFeedback,
            error: provider.feedbackError,
            feedback: feedbackData?['main_feedback'],
            improvementSuggestion: feedbackData?['improvement_suggestion'],
            onRetry: () => provider.requestLlmFeedback('tasks'),
          ),

          // List of already added tasks
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks added yet.'))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final points = challenge!.getPointsForTaskAtIndex(index);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(getIconForTask(task), color: Theme.of(context).colorScheme.primary),
                    title: Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(task.runtimeType.toString().replaceAll('Task', ' Task')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$points Pts',
                          style: TextStyle(
                            color: points > 0 ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.redAccent),
                          onPressed: () => provider.removeTaskFromChallenge(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}