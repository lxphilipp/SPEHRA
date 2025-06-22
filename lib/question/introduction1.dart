import 'package:flutter/material.dart';
import 'package:flutter_sdg/question/gettingStarted3.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff040324),
          title: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GettingStartedPage()),
              ),
              child: const Text(
                'skip',
                style: TextStyle(color: Color(0xff3BBE6B)),
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xff040324),
        body: Column(
          children: [
            const SizedBox(height: 20),
            RichText(
                text: const TextSpan(
                    style: TextStyle(fontSize: 30),
                    children: <TextSpan>[
                  TextSpan(
                      text: ' Hi,\n'
                          ' my name is ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'Sphera',
                      style: TextStyle(
                          color: Color(0xff3BBE6B),
                          fontStyle: FontStyle.italic)),
                  TextSpan(
                      text: ', I will \n'
                          ' try to help you to reach \n'
                          ' your sustainability goals.',
                      style: TextStyle(color: Colors.white)),
                ])),
            const SizedBox(height: 390),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                child: const Text('Continue',
                    style: TextStyle(
                        color: Color(0xff3BBE6B),
                        fontFamily: 'OswaldRegular',
                        fontSize: 30)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GettingStartedPage()),
                ),
              ),
            ),
          ],
        ));
  }
}
