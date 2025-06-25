// lib/features/introduction/presentation/widgets/question_widgets/getting_started_page_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/introduction_provider.dart';

class GettingStartedPageContent extends StatelessWidget {
  const GettingStartedPageContent({super.key});

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
              style: TextStyle(fontSize: 28, color: Colors.white),
              children: <TextSpan>[
                TextSpan(text: ' Would you mind \n'),
                TextSpan(
                  text: ' answering a few questions \n',
                  style: TextStyle(color: Color(0xff3BBE6B), fontStyle: FontStyle.italic),
                ),
                TextSpan(text: ' so we can provide you \n the best goal compatibility?'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.nextPage(context),
            child: const Text('Let\'s get started',
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