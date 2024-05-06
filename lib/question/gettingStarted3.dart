import 'package:flutter/material.dart';
import 'package:flutter_sdg/question/transport4.dart';

class GettingStartedPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff040324),
        appBar: AppBar(
          backgroundColor: const Color(0xff040324),
          title: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransportPage(),
                ),
              ),
              child: const Text(
                'skip',
                style: TextStyle(color: Color(0xff3BBE6B)),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            RichText(
                text: const TextSpan(
                    style: TextStyle(fontSize: 28),
                    children: <TextSpan>[
                  TextSpan(
                      text: ' Would you mind \n',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: ' answering a few questions \n',
                      style: TextStyle(
                          color: Color(0xff3BBE6B),
                          fontStyle: FontStyle.italic)),
                  TextSpan(
                      text: ' so we can provide you \n'
                          ' the best goal compatibility?',
                      style: TextStyle(color: Colors.white)),
                ])),
            const SizedBox(height: 375),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                child: const Text('Let\'s get started',
                    style: TextStyle(
                        color: Color(0xff3BBE6B),
                        fontFamily: 'OswaldRegular',
                        fontSize: 30)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransportPage(),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
