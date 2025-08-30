import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class EnergyPageContent extends StatefulWidget {
  const EnergyPageContent({super.key});

  @override
  State<EnergyPageContent> createState() => _EnergyPageContentState();
}

class _EnergyPageContentState extends State<EnergyPageContent> {
  String? _selectedOption;
  final List<String> energyOptions = ['Gas', 'Oil', 'Renewables', 'A Mix of Them'];

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
                      const TextSpan(text: 'What '),
                      TextSpan(
                        text: 'kind of energy',
                        style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' do you use in your household?'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: energyOptions.map((option) => _buildOptionButton(context, option)).toList(),
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