import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/challenges/presentation/widgets/creation_steps/task_selection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../domain/entities/trackable_task.dart';
import '../../../presentation/providers/challenge_provider.dart';

class Step4TasksPage extends StatelessWidget {
  const Step4TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();
    final challenge = provider.challengeInProgress;
    final tasks = challenge?.tasks ?? [];

    // Helper, um das richtige Icon für jeden Task-Typ zu bekommen
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
            'Füge nun die Aufgaben hinzu.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Eine gute Challenge hat mindestens eine beweisbare Aufgabe (z.B. Foto-Upload oder Standortbesuch).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Button zum Hinzufügen einer neuen Aufgabe
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Iconsax.add),
              label: const Text('Aufgabe hinzufügen'),
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

          // Liste der bereits hinzugefügten Aufgaben
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('Noch keine Aufgaben hinzugefügt.'))
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