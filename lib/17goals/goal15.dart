import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal15 extends StatelessWidget {
  const Goal15({super.key});

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
                            image: AssetImage(
                                'assets/icons/17_SDG_Icons/15.png'))),
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
                      "Life on land"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss. The goal intends to increase financial resources to conserve and sustainably use ecosystem and biodiversity; finance and incentivize sustainable forest management; combat global poaching and trafficking."),
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
                        'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/leben-an-land-1642288 '),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/biodiversity/'),
                    LinkText('https://www.bmz.de/de/agenda-2030/sdg-15'),
                    LinkText('https://sdgs.un.org/goals/goal15'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(child: const GoBackButton().build(context)),
              ],
            )),
      ),
    );
  }
}
