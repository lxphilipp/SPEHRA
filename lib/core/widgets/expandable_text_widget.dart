import 'package:flutter/material.dart';


class ExpandableTextWidget extends StatefulWidget {
  const ExpandableTextWidget({super.key});

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String fullText =
        'SPHERA makes it easier for you to implement the Sustainable Development Goals. Simple challenges will make your everyday life more sustainable, ecological and social. SPHERA offers you challenges for each of the 17 SDGs that you can master alone or with others. The app also provides you with further information on the SDGs and how you can get involved with them.';
    String previewText = '${fullText.substring(0, 100)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded ? fullText : previewText,
          style: const TextStyle(
            fontFamily: 'OswaldLight',
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? 'Read less' : 'Read more',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}