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
  final Set<String> selectedTopics = {};

  Widget _buildSelectableButton(String label) {
    final theme = Theme.of(context); // Theme für den Zugriff auf Farben holen
    final bool isSelected = selectedTopics.contains(label);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        // OPTIMIERT: Der Stil wird jetzt dynamisch aus dem Theme abgeleitet
        style: OutlinedButton.styleFrom(
          // Hintergrundfarbe ändert sich je nach Zustand
          backgroundColor: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.primary,
          ),
          foregroundColor: theme.colorScheme.onSurface, // Textfarbe für beide Zustände
        ),
        onPressed: () {
          setState(() {
            if (label == 'All') {
              selectedTopics.clear();
              selectedTopics.add('All');
            } else {
              selectedTopics.remove('All');
              if (isSelected) {
                selectedTopics.remove(label);
              } else {
                selectedTopics.add(label);
              }
            }
          });
        },
        child: Text(label, style: const TextStyle(fontSize: 19)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    final theme = Theme.of(context); // Theme für den Zugriff auf Farben holen

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => provider.nextPage(context),
                child: Text('skip', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  // OPTIMIERT: Basis-Stil aus dem Theme
                  style: theme.textTheme.headlineSmall,
                  children: <TextSpan>[
                    const TextSpan(text: 'What thoughts on the global sustainable development of our Sphere '),
                    TextSpan(
                      text: 'concern',
                      // OPTIMIERT: Akzentfarbe aus dem Theme
                      style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: ' you most?'),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: topics.map(_buildSelectableButton).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, top: 20),
          child: ElevatedButton(
            // OPTIMIERT: Der Stil wird vollständig vom globalen ElevatedButtonTheme gesteuert
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: selectedTopics.isNotEmpty ? () => provider.nextPage(context) : null,
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }
}