import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class SchoolPageContent extends StatefulWidget {
  const SchoolPageContent({super.key});

  @override
  State<SchoolPageContent> createState() => _SchoolPageContentState();
}

class _SchoolPageContentState extends State<SchoolPageContent> {
  String? _selectedOption;
  final List<String> schoolOptions = ['60%', '74%', '90%', '87%'];

  Widget _buildOptionButton(BuildContext context, String label) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedOption == label;

    return isSelected
        ? FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setState(() => _selectedOption = label),
      child: Text(label, style: const TextStyle(fontSize: 22)),
    )
        : OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      onPressed: () => setState(() => _selectedOption = label),
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
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.headlineSmall,
                    children: <TextSpan>[
                      const TextSpan(text: 'How many children do you think '),
                      TextSpan(
                        text: 'finish',
                        style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' primary school?'),
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
                  children: schoolOptions.map((option) => _buildOptionButton(context, option)).toList(),
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
            onPressed: _selectedOption != null ? () => provider.nextPage(context) : null,
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }
}