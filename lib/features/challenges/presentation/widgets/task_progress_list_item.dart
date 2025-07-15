import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/trackable_task.dart';
import '../../domain/entities/task_progress_entity.dart';
import '../providers/challenge_provider.dart';

class TaskProgressListItem extends StatelessWidget {
  final TrackableTask taskDefinition;
  final TaskProgressEntity? taskProgress;
  final int taskIndex;

  const TaskProgressListItem({
    super.key,
    required this.taskDefinition,
    required this.taskProgress,
    required this.taskIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChallengeProvider>();
    final isCompleted = taskProgress?.isCompleted ?? false;
    final theme = Theme.of(context);

    Widget trailingWidget = _buildTrailingWidget(context, provider, isCompleted, theme);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isCompleted ? 0 : 2,
      color: isCompleted ? theme.colorScheme.surfaceContainerHighest : theme.cardColor,
      child: ListTile(
        leading: _buildLeadingIcon(isCompleted, theme),
        title: Text(
          taskDefinition.description,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: isCompleted ? theme.disabledColor : theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: trailingWidget,
      ),
    );
  }

  /// Baut das Icon auf der linken Seite.
  Icon _buildLeadingIcon(bool isCompleted, ThemeData theme) {
    if (isCompleted) {
      return Icon(Iconsax.tick_circle, color: Colors.green);
    }

    IconData iconData;
    switch (taskDefinition.runtimeType) {
      case StepCounterTask:
        iconData = Iconsax.ruler;
        break;
      case LocationVisitTask:
        iconData = Iconsax.location;
        break;
      case ImageUploadTask:
        iconData = Iconsax.camera;
        break;
      default:
        iconData = Iconsax.task_square;
    }
    return Icon(iconData, color: theme.colorScheme.primary);
  }

  /// Baut den Untertitel, falls vorhanden (z.B. für Bilder).
  Widget? _buildSubtitle() {
    final imagePath = (taskProgress?.progressValue is String)
        ? taskProgress!.progressValue as String
        : null;
    if (taskDefinition is ImageUploadTask && imagePath != null && imagePath.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            File(imagePath),
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return null;
  }

  /// Baut das interaktive Widget auf der rechten Seite.
  Widget _buildTrailingWidget(BuildContext context, ChallengeProvider provider, bool isCompleted, ThemeData theme) {
    // Das ist der Schlüssel: Wir verwenden einen AnimatedSwitcher.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300), // Dauer der Animation
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Eine einfache Ein-/Ausblend-Animation
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentTrailingState(context, provider, isCompleted, theme),
    );
  }

  /// Diese neue Hilfsmethode entscheidet, welches Widget (Icon oder Ladekreis)
  /// im AnimatedSwitcher angezeigt werden soll.
  Widget _buildCurrentTrailingState(BuildContext context, ChallengeProvider provider, bool isCompleted, ThemeData theme) {
    // Wir prüfen, ob GENAU DIESER Task gerade lädt.
    if (provider.isVerifyingTask(taskIndex)) {
      // WICHTIG: Wir geben dem Ladekreis einen festen Container,
      // der die gleiche Größe hat wie die Klickfläche eines IconButtons,
      // um das "Springen" zu verhindern.
      return Container(
        key: const ValueKey('loader'), // Eindeutiger Schlüssel für die Animation
        width: 48.0,
        height: 48.0,
        padding: const EdgeInsets.all(12.0), // Padding, um den Kreis kleiner zu machen
        child: const CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    // Wenn nicht geladen wird, bauen wir das passende Icon-Widget.
    // Wir geben ihm einen Schlüssel, damit der AnimatedSwitcher weiß, dass es ein neues Widget ist.
    switch (taskDefinition) {
      case CheckboxTask():
        return Checkbox(
          key: const ValueKey('checkbox'),
          value: isCompleted,
          onChanged: (bool? value) {
            if (value != null) provider.toggleCheckboxTask(taskIndex, value);
          },
        );

      case StepCounterTask():
        final stepsDone = (taskProgress?.progressValue as int?) ?? 0;
        final target = (taskDefinition as StepCounterTask).targetSteps;
        return TextButton(
          key: const ValueKey('steps'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$stepsDone / $target', style: theme.textTheme.bodyMedium),
              const Text('Refresh', style: TextStyle(fontSize: 12)),
            ],
          ),
          onPressed: () => provider.refreshStepCounterTask(taskIndex),
        );

      case LocationVisitTask():
        return IconButton(
          key: const ValueKey('location'),
          icon: Icon(Iconsax.location_tick, color: isCompleted ? Colors.green : theme.iconTheme.color),
          tooltip: "Check-in",
          onPressed: isCompleted ? null : () => provider.verifyLocationForTask(taskIndex),
        );

      case ImageUploadTask():
        if (isCompleted) {
          return const Icon(Icons.check_circle, color: Colors.green, key: ValueKey('image_done'));
        }
        return IconButton(
          key: const ValueKey('image'),
          icon: const Icon(Iconsax.camera),
          tooltip: "Bild als Beweis auswählen",
          onPressed: () => provider.selectImageForTask(taskIndex),
        );

      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }
}