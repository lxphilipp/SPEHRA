import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/challenges/presentation/widgets/creation_steps/task_forms/location_visit_task_form.dart';
import 'package:flutter_sdg/features/challenges/presentation/widgets/creation_steps/task_forms/step_counter_task_form.dart';
import 'package:flutter_sdg/features/challenges/presentation/widgets/creation_steps/task_forms/task_configuration_dialog.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/trackable_task.dart';
import '../../providers/challenge_provider.dart';


class TaskSelectionDialog extends StatelessWidget {
  final ChallengeProvider challengeProvider;
  const TaskSelectionDialog({super.key, required this.challengeProvider});

  void _showSimpleTaskConfigDialog(BuildContext context, String title, String hint, Function(String) onSave) {
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => TaskConfigurationDialog(
        title: title,
        formContent: TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'Aufgabenbeschreibung', hintText: hint),
          autofocus: true,
        ),
        onSave: () {
          if (descriptionController.text.isNotEmpty) {
            onSave(descriptionController.text);
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showStepCounterDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final stepsController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => TaskConfigurationDialog(
        title: 'Schrittzähler-Aufgabe erstellen',
        formContent: StepCounterTaskForm(
          descriptionController: descriptionController,
          stepsController: stepsController,
        ),
        onSave: () {
          if (descriptionController.text.isNotEmpty && stepsController.text.isNotEmpty) {
            final steps = int.tryParse(stepsController.text) ?? 0;
            if (steps > 0) {
              challengeProvider.addTaskToChallenge(
                StepCounterTask(description: descriptionController.text, targetSteps: steps),
              );
              Navigator.of(context).pop();
            }
          }
        },
      ),
    );
  }

  void _showLocationVisitDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final radiusController = TextEditingController(text: '50');
    LatLng selectedLocation = const LatLng(49.756, 6.641);

    showDialog(
      context: context,
      builder: (_) => TaskConfigurationDialog(
        title: 'Standort-Aufgabe erstellen',
        formContent: LocationVisitTaskForm(
          descriptionController: descriptionController,
          radiusController: radiusController,
          initialLocation: selectedLocation,
          onLocationChanged: (newLocation) {
            selectedLocation = newLocation;
          },
        ),
        onSave: () {
          final description = descriptionController.text;
          final radius = double.tryParse(radiusController.text) ?? 50.0;
          if (description.isNotEmpty) {
            challengeProvider.addTaskToChallenge(
              LocationVisitTask(
                description: description,
                latitude: selectedLocation.latitude,
                longitude: selectedLocation.longitude,
                radius: radius,
              ),
            );
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wähle einen Aufgabentyp'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.task_square),
              title: const Text('Einfache Aufgabe'),
              onTap: () {
                _showSimpleTaskConfigDialog(context, 'Einfache Aufgabe erstellen', 'z.B. "Regionales Gemüse kaufen"', (desc) {
                  challengeProvider.addTaskToChallenge(CheckboxTask(description: desc));
                });
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('Foto-Beweis'),
              onTap: () {
                _showSimpleTaskConfigDialog(context, 'Foto-Aufgabe erstellen', 'z.B. "Fotografiere dein Insektenhotel"', (desc) {
                  challengeProvider.addTaskToChallenge(ImageUploadTask(description: desc));
                });
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.ruler),
              title: const Text('Schrittzähler'),
              onTap: () => _showStepCounterDialog(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.location),
              title: const Text('Standortbesuch'),
              onTap: () => _showLocationVisitDialog(context),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Schließen'))
      ],
    );
  }
}