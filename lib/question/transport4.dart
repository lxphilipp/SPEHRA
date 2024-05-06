import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sdg/homepage/homepage.dart';

class TransportPage extends StatelessWidget {
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
                  builder: (context) => const HomePage(),
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
                    style: TextStyle(fontSize: 29),
                    children: <TextSpan>[
                  TextSpan(
                      text: ' What is your go to ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'method \n of transport',
                      style: TextStyle(
                          color: Color(0xff3BBE6B),
                          fontStyle: FontStyle.italic)),
                  TextSpan(
                    text: '?',
                    style: TextStyle(color: Colors.white),
                  )
                ])),
            const SizedBox(height: 20),
            Row(
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xff3BBE6B))),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Placeholder())),
                    child: const Text('Car',
                        style: TextStyle(color: Colors.white))),
              ],
            )
          ],
        ));
  }
}
