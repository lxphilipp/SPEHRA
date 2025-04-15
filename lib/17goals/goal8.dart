import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal8 extends StatelessWidget {
  const Goal8({super.key});

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
                                AssetImage('assets/icons/17_SDG_Icons/8.png'))),
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
                      "Decent work and economic growth"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "For close to three decades, the number of workers living in extreme poverty has reduced drastically. This is despite the lasting impact of the 2008 economic crisis and global recession. In developing countries, 34 per cent of total employments were for the middle class, a number that has increased rapidly between 1991 and 2015. SDG 8 aims at fostering sustainable and equitable economic growth for all workers, irrespective of their background, race or gender."),
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
                    LinkText('https://sdgs.un.org/goals/goal8'),
                    LinkText(
                        'https://unstats.un.org/sdgs/report/2022/goal-08/'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/economic-growth/'),
                    LinkText('https://www.worldbank.org/en/topic'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                // const GoBackButton().build(context),
                Center(child: GoBackButton().build(context)),
              ],
            )),
      ),
    );
  }
}
