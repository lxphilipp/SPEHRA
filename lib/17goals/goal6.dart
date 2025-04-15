import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal6 extends StatelessWidget {
  const Goal6({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginLayout(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/icons/17_SDG_Icons/6.png'))),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: const Text(
                      style: TextStyle(
                          fontFamily: 'OswaldLight',
                          color: Colors.white,
                          fontSize: 45),
                      "Clean water and sanitation"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    " \"Clean water and sanitation for all\". It is one of the 17 Sustainable Development Goals established by the United Nations General Assembly in 2015. According to the United Nations, the goal is to: \"Ensure availability and sustainable management of water and sanitation for all.\"Like the others, this Sustainable Development goal is interrelated with the other SDGs. For example, access to clean water will improve o health and wellbeing, leading to a progress in SDG3"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'More Information at:',
                      style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    LinkText(
                        'https://unstats.un.org/sdgs/report/2022/goal-06/'),
                    LinkText('https://sdgs.un.org/goals/goal6'),
                    LinkText('https://www.unwater.org/'),
                    LinkText('https://www.un.org/en/observances/water-day'),
                  ],
                ),
                //const GoBackButton().build(context),
                Center(child: GoBackButton().build(context)),
              ],
            )),
      ),
    );
  }
}
