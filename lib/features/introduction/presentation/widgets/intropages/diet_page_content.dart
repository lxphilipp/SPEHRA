import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

// Convert to a StatefulWidget to manage the selection state
class DietPageContent extends StatefulWidget {
  const DietPageContent({super.key});

  @override
  State<DietPageContent> createState() => _DietPageContentState();
}

class _DietPageContentState extends State<DietPageContent> {
  String? _selectedOption;

  final List<String> dietOptions = ['Vegan', 'Vegetarian', 'Pescatarian', 'Omnivore'];

  // This build method for the buttons now handles selection state
  Widget _buildOptionButton(BuildContext context, String label) {
    final theme = Theme.of(context);
    // Check if this button is the currently selected one
    final bool isSelected = _selectedOption == label;

    // Use a FilledButton for the selected state for clear visual feedback
    return isSelected
        ? FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        // 2. Update the state when a button is pressed
        setState(() {
          _selectedOption = label;
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 22)),
    )
        : OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () {
        // 2. Update the state when a button is pressed
        setState(() {
          _selectedOption = label;
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 16.0),
            child: TextButton(
              onPressed: () => provider.nextPage(context),
              child: Text('skip', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: RichText(
                  textAlign: TextAlign.center, // Center the text
                  text: TextSpan(
                    style: theme.textTheme.headlineSmall,
                    children: <TextSpan>[
                      const TextSpan(text: ' What does your '),
                      TextSpan(
                        text: 'diet',
                        style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' look\n like?'), // Adjusted line break for better centering
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: dietOptions.map((option) => _buildOptionButton(context, option)).toList(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, top: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            // 3. Enable the button only when an option is selected
            onPressed: _selectedOption != null ? () => provider.nextPage(context) : null,
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }
}