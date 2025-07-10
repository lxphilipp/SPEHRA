import 'package:flutter/material.dart';

class TaskConfigurationDialog extends StatelessWidget {
  final String title;
  final Widget formContent;
  final VoidCallback onSave;
  final bool isSaveEnabled;

  const TaskConfigurationDialog({
    super.key,
    required this.title,
    required this.formContent,
    required this.onSave,
    this.isSaveEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: formContent,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
        FilledButton(onPressed: isSaveEnabled ? onSave : null, child: const Text('Hinzufügen')),
      ],
    );
  }
}