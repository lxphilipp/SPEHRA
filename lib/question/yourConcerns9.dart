// import 'package:flutter/material.dart';
// import 'package:flutter_sdg/homepage/home_screen.dart';

// class YourConcernsPage extends StatelessWidget {
//   const YourConcernsPage({Key? key}) : super(key: key);

//   final double fontSize = 19;

//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff040324),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: const Color(0xff040324),
//         title: Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const HomePageScreen(),
//               ),
//             ),
//             child: const Text(
//               'skip',
//               style: TextStyle(color: Color(0xff3BBE6B)),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: RichText(
//                 text: const TextSpan(
//                     style: TextStyle(fontSize: 32),
//                     children: <TextSpan>[
//                   TextSpan(
//                       text:
//                           'What thoughts on the global sustainable development of our Sphere  ',
//                       style: TextStyle(color: Colors.white)),
//                   TextSpan(
//                       text: 'concern',
//                       style: TextStyle(
//                           color: Color(0xff3BBE6B),
//                           fontStyle: FontStyle.italic)),
//                   TextSpan(
//                     text: ' you most ?',
//                     style: TextStyle(color: Colors.white),
//                   )
//                 ])),
//           ),
//           const SizedBox(height: 200),
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 0,
//                   horizontal: 20,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           side: const BorderSide(
//                               color: Color(
//                             0xff3BBE6B,
//                           ))),
//                       onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const HomePageScreen())),
//                       child: Text('Means of transportion',
//                           style: TextStyle(
//                               color: Colors.white, fontSize: fontSize))),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 0,
//                   horizontal: 20,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           side: const BorderSide(
//                               color: Color(
//                             0xff3BBE6B,
//                           ))),
//                       onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const HomePageScreen())),
//                       child: Text('Environmental pollution',
//                           style: TextStyle(
//                               color: Colors.white, fontSize: fontSize))),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 0,
//                   horizontal: 20,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           side: const BorderSide(
//                               color: Color(
//                             0xff3BBE6B,
//                           ))),
//                       onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const HomePageScreen())),
//                       child: Text('Food & Consumption',
//                           style: TextStyle(
//                               color: Colors.white, fontSize: fontSize))),
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                         ),
//                         child: OutlinedButton(
//                             style: OutlinedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                                 side: const BorderSide(
//                                     color: Color(
//                                   0xff3BBE6B,
//                                 ))),
//                             onPressed: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         const HomePageScreen())),
//                             child: Text('War & Peace',
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: fontSize))),
//                       ),
//                       OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                               side: const BorderSide(color: Color(0xff3BBE6B))),
//                           onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       const HomePageScreen())),
//                           child: Text('Social Equality',
//                               style: TextStyle(
//                                   color: Colors.white, fontSize: fontSize))),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2, horizontal: 10),
//                       child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                               side: const BorderSide(color: Color(0xff3BBE6B))),
//                           onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       const HomePageScreen())),
//                           child: Text('Climate Change',
//                               style: TextStyle(
//                                   color: Colors.white, fontSize: fontSize))),
//                     ),
//                     OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10)),
//                             side: const BorderSide(color: Color(0xff3BBE6B))),
//                         onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const HomePageScreen())),
//                         child: Text('All',
//                             style: TextStyle(
//                                 color: Colors.white, fontSize: fontSize))),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ],
//       )),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/home/presentation/screens/home_screen.dart';

class YourConcernsPage extends StatefulWidget {
  const YourConcernsPage({super.key});

  @override
  State<YourConcernsPage> createState() => _YourConcernsPageState();
}

class _YourConcernsPageState extends State<YourConcernsPage> {
  final double fontSize = 19;

  final List<String> topics = [
    'Means of transportion',
    'Environmental pollution',
    'Food & Consumption',
    'War & Peace',
    'Social Equality',
    'Climate Change',
    'All',
  ];

  final Set<String> selectedTopics = {};

  Widget _buildSelectableButton(String label) {
    final bool isSelected = selectedTopics.contains(label);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xff3BBE6B).withOpacity(0.3)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Color(0xff3BBE6B)),
        ),
        onPressed: () {
          setState(() {
            if (isSelected) {
              selectedTopics.remove(label);
            } else {
              selectedTopics.add(label);
            }
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  @override
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
                builder: (context) => const HomeScreen(),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.start,
              children: topics.map(_buildSelectableButton).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3BBE6B),
                foregroundColor: Colors.white,
              ),
              onPressed: selectedTopics.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  : null,
              child: const Text("Continue"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
