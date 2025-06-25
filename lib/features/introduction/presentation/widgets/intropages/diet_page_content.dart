// lib/features/introduction/presentation/widgets/question_widgets/diet_page_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class DietPageContent extends StatelessWidget {
  const DietPageContent({super.key});

  Widget _buildOptionButton(BuildContext context, String label) {
    final provider = context.read<IntroductionProvider>();
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xff3BBE6B)),
      ),
      onPressed: () {
        // Hier könntest du die Auswahl speichern, z.B. im Provider
        // provider.saveAnswer('diet', label);
        provider.nextPage(context);
      },
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 22)),
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
                  style: TextStyle(fontSize: 30, color: Colors.white),
                  children: <TextSpan>[
                    TextSpan(text: ' What does your '),
                    TextSpan(
                      text: 'diet',
                      style: TextStyle(color: Color(0xff3BBE6B), fontStyle: FontStyle.italic),
                    ),
                    TextSpan(text: ' look\n like ?'),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0, left: 20, right: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildOptionButton(context, 'Vegan'),
              _buildOptionButton(context, 'Vegetarian'),
              _buildOptionButton(context, 'Pescatarian'),
              _buildOptionButton(context, 'Omnivore'),
            ],
          ),
        ),
      ],
    );
  }
}