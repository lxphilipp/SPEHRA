import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class YourConcernsPageContent extends StatefulWidget {
  const YourConcernsPageContent({super.key});

  @override
  State<YourConcernsPageContent> createState() => _YourConcernsPageContentState();
}

class _YourConcernsPageContentState extends State<YourConcernsPageContent> {
  final List<String> topics = [
    'Means of transportion', 'Environmental pollution', 'Food & Consumption',
    'War & Peace', 'Social Equality', 'Climate Change', 'All',
  ];
  // State variable to hold the multiple selections
  final Set<String> _selectedTopics = {};

  Widget _buildSelectableButton(String label) {
    final theme = Theme.of(context);
    // Check if the current button's label is in our set of selected topics
    final bool isSelected = _selectedTopics.contains(label);

    return isSelected
        ? FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        // Update state for selection
        setState(() {
          // Logic to handle "All" and individual selections
          if (label == 'All') {
            if (isSelected) {
              _selectedTopics.clear();
            } else {
              _selectedTopics.clear();
              _selectedTopics.add('All');
            }
          } else {
            _selectedTopics.remove('All'); // Deselect "All" if an individual item is tapped
            if (isSelected) {
              _selectedTopics.remove(label);
            } else {
              _selectedTopics.add(label);
            }
          }
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 19)),
    )
        : OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () {
        setState(() {
          if (label == 'All') {
            _selectedTopics.clear();
            _selectedTopics.add('All');
          } else {
            _selectedTopics.remove('All');
            if (isSelected) {
              _selectedTopics.remove(label);
            } else {
              _selectedTopics.add(label);
            }
          }
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 19)),
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
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.headlineSmall,
                    children: <TextSpan>[
                      const TextSpan(text: 'What thoughts on the global sustainable development of our Sphere '),
                      TextSpan(
                        text: 'concern',
                        style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' you most?'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: topics.map(_buildSelectableButton).toList(),
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
            // Button is enabled only when the selection set is not empty
            onPressed: _selectedTopics.isNotEmpty ? () => provider.nextPage(context) : null,
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }
}