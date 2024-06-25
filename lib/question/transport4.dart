import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sdg/question/diet5.dart';

class TransportPage extends StatelessWidget {
  final double fontSize = 22;

  const TransportPage({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff040324),
        title: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DietPage(),
              ),
            ),
            child: const Text(
              'skip',
              style: TextStyle(color: Color(0xff3BBE6B)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: RichText(
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
          ),
          const SizedBox(height: 420),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(
                                  color: Color(
                                0xff3BBE6B,
                              ))),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DietPage())),
                          child: Text(' Car ',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize))),
                    ),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: Color(0xff3BBE6B))),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DietPage())),
                        child: Text(' Public Transport ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize))),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 10),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: Color(0xff3BBE6B))),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DietPage())),
                          child: Text('  By foot  ',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize))),
                    ),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: Color(0xff3BBE6B))),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DietPage())),
                        child: Text('   Air plane    ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize))),
                  ],
                ),
              )
            ],
          ),
        ],
      )),
    );
  }
}
