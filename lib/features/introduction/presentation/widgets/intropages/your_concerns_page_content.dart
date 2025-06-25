// lib/features/introduction/presentation/widgets/question_widgets/your_concerns_page_content.dart
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
    final bool isSelected = selectedTopics.contains(label);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xff3BBE6B).withOpacity(0.3) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Color(0xff3BBE6B)),
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
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 19)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => provider.nextPage(context),
                child: const Text('skip', style: TextStyle(color: Color(0xff3BBE6B))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  children: <TextSpan>[
                    TextSpan(text: 'What thoughts on the global sustainable development of our Sphere '),
                    TextSpan(text: 'concern', style: TextStyle(color: Color(0xff3BBE6B), fontStyle: FontStyle.italic)),
                    TextSpan(text: ' you most?'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3BBE6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: selectedTopics.isNotEmpty
                ? () => provider.nextPage(context)
                : null, // Button ist deaktiviert, wenn nichts ausgewählt ist
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }
}