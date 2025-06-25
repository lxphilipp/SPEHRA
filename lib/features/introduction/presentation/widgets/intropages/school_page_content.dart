// lib/features/introduction/presentation/widgets/question_widgets/school_page_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class SchoolPageContent extends StatelessWidget {
  const SchoolPageContent({super.key});

  Widget _buildOptionButton(BuildContext context, String label) {
    final provider = context.read<IntroductionProvider>();
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xff3BBE6B)),
      ),
      onPressed: () => provider.nextPage(context),
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
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  children: <TextSpan>[
                    TextSpan(text: 'How many children do you think '),
                    TextSpan(
                      text: 'finish',
                      style: TextStyle(color: Color(0xff3BBE6B), fontStyle: FontStyle.italic),
                    ),
                    TextSpan(text: ' primary school?'),
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
              _buildOptionButton(context, '60%'),
              _buildOptionButton(context, '74%'),
              _buildOptionButton(context, '90%'),
              _buildOptionButton(context, '87%'),
            ],
          ),
        ),
      ],
    );
  }
}