import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für FilteringTextInputFormatter
import 'package:provider/provider.dart';
// Für Theme-Zugriff
import '../providers/challenge_provider.dart';

class CreateChallengeForm extends StatefulWidget {
  const CreateChallengeForm({super.key});

  @override
  State<CreateChallengeForm> createState() => _CreateChallengeFormState();
}

class _CreateChallengeFormState extends State<CreateChallengeForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskController = TextEditingController();
  final _pointsController = TextEditingController();

  String _selectedDifficulty = "Easy";
  final List<String> _difficultyOptions = ["Easy", "Normal", "Advanced", "Experienced"]; // Deine Optionen
  final List<String> _categoryKeys = List.generate(17, (i) => 'goal${i + 1}');
  final List<String> _categoryImagePaths = List.generate(17, (i) => 'assets/icons/17_SDG_Icons/${i + 1}.png');
  final List<String> _selectedCategories = []; // Hält die ausgewählten SDG-Keys

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _taskController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _showSnackbarMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
      ),
    );
  }

  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return; // Formular ist nicht valide
    }
    if (_selectedCategories.isEmpty) {
      _showSnackbarMessage('Please select at least one SDG category.', isError: true);
      return;
    }

    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);

    final success = await challengeProvider.createChallenge(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      task: _taskController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      categories: _selectedCategories,
      difficulty: _selectedDifficulty,
    );

    if (!mounted) return;
    if (success) {
      _showSnackbarMessage('Challenge saved successfully!');
      Navigator.pop(context); // Zurück zum vorherigen Screen
    } else {
      _showSnackbarMessage(challengeProvider.createChallengeError ?? 'Error saving challenge.', isError: true);
    }
  }

  Widget _buildSdgCategoryPicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select SDG Categories:", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List.generate(_categoryKeys.length, (index) {
            final key = _categoryKeys[index];
            final imagePath = _categoryImagePaths[index];
            final isSelected = _selectedCategories.contains(key);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(key);
                  } else {
                    _selectedCategories.add(key);
                  }
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade700,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            );
          }),
        ),
        if (_selectedCategories.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text("Selected: ${_selectedCategories.join(', ')}", style: theme.textTheme.bodySmall),
        ]
      ],
    );
  }

  Widget _buildDifficultyPicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Difficulty:", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDifficulty,
          items: _difficultyOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedDifficulty = newValue;
              });
            }
          },
          decoration: _inputDecoration(theme, "Difficulty"),
          dropdownColor: theme.cardColor, // Hintergrund des Dropdowns
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceContainerHighest,
      border: theme.inputDecorationTheme.border ?? const OutlineInputBorder(),
      enabledBorder: theme.inputDecorationTheme.enabledBorder,
      focusedBorder: theme.inputDecorationTheme.focusedBorder,
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challengeProvider = Provider.of<ChallengeProvider>(context); // Für Ladezustand

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSdgCategoryPicker(theme),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              style: theme.textTheme.bodyMedium,
              decoration: _inputDecoration(theme, "Title"),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: theme.textTheme.bodyMedium,
              decoration: _inputDecoration(theme, "Description"),
              maxLines: 3,
              minLines: 1,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taskController,
              style: theme.textTheme.bodyMedium,
              decoration: _inputDecoration(theme, "Task"),
              maxLines: 3,
              minLines: 1,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a task' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pointsController,
              style: theme.textTheme.bodyMedium,
              decoration: _inputDecoration(theme, "Points"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter points';
                if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Please enter a valid number of points';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDifficultyPicker(theme),
            const SizedBox(height: 30),
            ElevatedButton(
              style: theme.elevatedButtonTheme.style,
              onPressed: challengeProvider.isCreatingChallenge ? null : _saveChallenge,
              child: challengeProvider.isCreatingChallenge
                  ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Challenge'),
            ),
            if (challengeProvider.createChallengeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  challengeProvider.createChallengeError!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              )
          ],
        ),
      ),
    );
  }
}