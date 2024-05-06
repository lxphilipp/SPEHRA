import 'package:flutter/material.dart';
import 'package:flutter_sdg/question/gettingStarted3.dart';

class NamePage extends StatelessWidget {
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
                  builder: (context) => GettingStartedPage(),
                ),
              ),
              child: const Text(
                'skip',
                style: TextStyle(color: Color(0xff3BBE6B)),
              ),
            ),
          ),
        ),
        body: Column(children: [
          const SizedBox(height: 20),
          RichText(
              text: const TextSpan(
                  style: TextStyle(fontSize: 30),
                  children: <TextSpan>[
                TextSpan(
                    text: ' But enough about me,\n what is ',
                    style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'your name',
                  style: TextStyle(
                    color: Color(0xff3BBE6B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(text: '?', style: TextStyle(color: Colors.white)),
              ])),
          const SizedBox(
            height: 440,
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: TextButton(
              child: const Text('Continue',
                  style: TextStyle(
                      color: Color(0xff3BBE6B),
                      fontFamily: 'OswaldRegular',
                      fontSize: 30)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GettingStartedPage(),
                ),
              ),
            ),
          ),
        ]));
  }
}
