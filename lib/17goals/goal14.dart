import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal14 extends StatelessWidget {
  const Goal14({super.key});

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
                                'assets/icons/17_SDG_Icons/14.png'))),
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
                      "Life below water"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "The deterioration of coastal waters has become a global occurrence, due to pollution and coastal eutrophication (overflow of nutrients in water), where similar contributing factors to climate change can affect oceans and negatively impact marine biodiversity. It has been pointed out in 2018 that \"without concerted efforts, coastal eutrophication is expected to increase in 20 per cent of large marine ecosystems by 2050.\""),
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
                    LinkText('https://sdgs.un.org/goals/goal14'),
                    LinkText(
                        'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/leben-unter-wasser-schuetzen-1522310'),
                    LinkText('https://www.bmz.de/de/agenda-2030/sdg-14'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/oceans/'),
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
