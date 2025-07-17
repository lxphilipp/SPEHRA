import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The form for configuring a StepCounterTask.
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
            labelText: 'Task Description',
            hintText: 'e.g. "Go for a walk today"',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: stepsController,
          decoration: const InputDecoration(
            labelText: 'Step Goal',
            hintText: 'e.g. "5000"',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}