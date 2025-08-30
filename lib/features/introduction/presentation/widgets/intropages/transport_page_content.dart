import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class TransportPageContent extends StatefulWidget {
  const TransportPageContent({super.key});

  @override
  State<TransportPageContent> createState() => _TransportPageContentState();
}

class _TransportPageContentState extends State<TransportPageContent> {
  String? _selectedOption;
  final List<String> transportOptions = ['Car', 'Public Transport', 'By foot', 'Airplane'];

  Widget _buildOptionButton(BuildContext context, String label) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedOption == label;

    return isSelected
        ? FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setState(() => _selectedOption = label),
      child: Text(label, style: const TextStyle(fontSize: 22)),
    )
        : OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      const TextSpan(text: 'What is your go to '),
                      TextSpan(
                        text: 'method of transport',
                        style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: '?'),
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
                  children: transportOptions.map((option) => _buildOptionButton(context, option)).toList(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
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