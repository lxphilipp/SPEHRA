// import 'package:flutter/material.dart';
// import 'package:flutter_sdg/question/school7.dart';

// class EnergyPage extends StatelessWidget {
//   const EnergyPage({Key? key}) : super(key: key);

//   final double fontSize = 22;

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
//                 builder: (context) => const SchoolPage(),
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
//         children: [
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: RichText(
//                 text: const TextSpan(
//                     style: TextStyle(fontSize: 32),
//                     children: <TextSpan>[
//                   TextSpan(
//                       text: 'What ', style: TextStyle(color: Colors.white)),
//                   TextSpan(
//                       text: 'kind of energy',
//                       style: TextStyle(
//                           color: Color(0xff3BBE6B),
//                           fontStyle: FontStyle.italic)),
//                   TextSpan(
//                     text: ' do     you use in your      household ?',
//                     style: TextStyle(color: Colors.white),
//                   )
//                 ])),
//           ),
//           const SizedBox(height: 400),
//           Column(
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                       ),
//                       child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                               side: const BorderSide(
//                                   color: Color(
//                                 0xff3BBE6B,
//                               ))),
//                           onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const SchoolPage())),
//                           child: Text(' Gas ',
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
//                                 builder: (context) => const SchoolPage())),
//                         child: Text('   Oil   ',
//                             style: TextStyle(
//                                 color: Colors.white, fontSize: fontSize))),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//                 child: Row(
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
//                                   builder: (context) => const SchoolPage())),
//                           child: Text('Renewables',
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
//                                 builder: (context) => const SchoolPage())),
//                         child: Text('A Mix of Them',
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
import 'package:flutter_sdg/question/school7.dart';

class EnergyPage extends StatelessWidget {
  const EnergyPage({super.key});

  final double fontSize = 22;

  Widget _buildOptionButton(BuildContext context, String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: Color(0xff3BBE6B)),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SchoolPage()),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 22),
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
                builder: (context) => const SchoolPage(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 32),
                children: <TextSpan>[
                  TextSpan(
                      text: 'What ', style: TextStyle(color: Colors.white)),
                  TextSpan(
                    text: 'kind of energy',
                    style: TextStyle(
                      color: Color(0xff3BBE6B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: ' do     you use in your      household ?',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildOptionButton(context, 'Gas'),
                _buildOptionButton(context, 'Oil'),
                _buildOptionButton(context, 'Renewables'),
                _buildOptionButton(context, 'A Mix of Them'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
