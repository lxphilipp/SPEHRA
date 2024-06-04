import 'package:flutter/material.dart';
import 'package:flutter_sdg/question/SDG8.dart';

class SchoolPage extends StatelessWidget {
  const SchoolPage({Key? key}) : super(key: key);

  final double fontSize = 22;

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
                builder: (context) => const SDGPage(),
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
                    style: TextStyle(fontSize: 32),
                    children: <TextSpan>[
                  TextSpan(
                      text: 'How many children do you think ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'finish',
                      style: TextStyle(
                          color: Color(0xff3BBE6B),
                          fontStyle: FontStyle.italic)),
                  TextSpan(
                    text: ' primary school ?',
                    style: TextStyle(color: Colors.white),
                  )
                ])),
          ),
          const SizedBox(height: 400),
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
                                  builder: (context) => const Placeholder())),
                          child: Text(' Vegan ',
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
                                builder: (context) => const Placeholder())),
                        child: Text('   Vegeterian   ',
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
                                  builder: (context) => const Placeholder())),
                          child: Text('Pescerian',
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
                                builder: (context) => const Placeholder())),
                        child: Text('Omnivorian',
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
