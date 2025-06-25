// lib/features/introduction/presentation/widgets/question_widgets/introduction_page_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class IntroductionPageContent extends StatelessWidget {
  const IntroductionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroductionProvider>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 30, color: Colors.white),
              children: <TextSpan>[
                TextSpan(text: ' Hi,\n my name is '),
                TextSpan(
                  text: 'Sphera',
                  style: TextStyle(color: Color(0xff3BBE6B), fontStyle: FontStyle.italic),
                ),
                TextSpan(text: ', I will \n try to help you to reach \n your sustainability goals.'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.nextPage(context), // <-- Ruft die Provider-Methode auf
            child: const Text('Continue',
                style: TextStyle(
                    color: Color(0xff3BBE6B),
                    fontFamily: 'OswaldRegular',
                    fontSize: 30)),
          ),
        ],
      ),
    );
  }
}