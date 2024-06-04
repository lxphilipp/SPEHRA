import 'package:flutter/material.dart';
import 'package:flutter_sdg/homepage/homepage.dart';

class YourConcernsPage extends StatelessWidget {
  const YourConcernsPage({Key? key}) : super(key: key);

  final double fontSize = 19;

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
                builder: (context) => const HomePageScreen(),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: RichText(
                text: const TextSpan(
                    style: TextStyle(fontSize: 32),
                    children: <TextSpan>[
                  TextSpan(
                      text:
                          'What thoughts on the global sustainable development of our Sphere  ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'concern',
                      style: TextStyle(
                          color: Color(0xff3BBE6B),
                          fontStyle: FontStyle.italic)),
                  TextSpan(
                    text: ' you most ?',
                    style: TextStyle(color: Colors.white),
                  )
                ])),
          ),
          const SizedBox(height: 200),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
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
                      child: Text('Means of transportion',
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
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
                      child: Text('Environmental pollution',
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
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
                      child: Text('Food & Consumption',
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
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
                            child: Text('War & Peace',
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
                          child: Text('Social Equality',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize))),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                          child: Text('Climate Change',
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
                        child: Text('All',
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
