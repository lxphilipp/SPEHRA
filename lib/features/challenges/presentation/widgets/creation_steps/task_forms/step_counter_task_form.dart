import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Das Formular zur Konfiguration einer StepCounterTask.
class StepCounterTaskForm extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController stepsController;

  const StepCounterTaskForm({
    super.key,
    required this.descriptionController,
    required this.stepsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Aufgabenbeschreibung',
            hintText: 'z.B. "Gehe heute spazieren"',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: stepsController,
          decoration: const InputDecoration(
            labelText: 'Schrittziel',
            hintText: 'z.B. "5000"',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}