import 'package:flutter/material.dart';
import 'package:flutter_sdg/question/yourConcerns9.dart';

class SDGPage extends StatelessWidget {
  const SDGPage({Key? key}) : super(key: key);

  final double fontSize = 20;

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
                builder: (context) => const YourConcernsPage(),
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
                      text: 'How much do you know about the UN\'s ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'Sustainability Development Goals',
                      style: TextStyle(
                          color: Color(0xff3BBE6B),
                          fontStyle: FontStyle.italic)),
                  TextSpan(
                    text: '(SDGs) ?',
                    style: TextStyle(color: Colors.white),
                  )
                ])),
          ),
          const SizedBox(height: 285),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
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
                            builder: (context) => const YourConcernsPage())),
                    child: Text(' Never heard of them',
                        style: TextStyle(
                            color: Colors.white, fontSize: fontSize))),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  builder: (context) =>
                                      const YourConcernsPage())),
                          child: Text('hardly anything',
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
                                builder: (context) =>
                                    const YourConcernsPage())),
                        child: Text(' a little ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize))),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  builder: (context) =>
                                      const YourConcernsPage())),
                          child: Text('quite a bit',
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
                                builder: (context) =>
                                    const YourConcernsPage())),
                        child: Text('I\'m an expert',
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
