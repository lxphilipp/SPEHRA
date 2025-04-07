import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
import 'package:url_launcher/link.dart';

class Goal10 extends StatelessWidget {
  const Goal10({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginLayout(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage('assets/icons/17_SDG_Icons/10.png'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 45),
                    "Reduced Inequality"),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "Inequality exist in various forms, such as economic, sex, disability, race, social inequality, and different forms of discrimination. Measuring inequality in its individual forms is a crucial component in order to reduce inequality within and among countries. The Gini coefficient is the most frequently used measurement of socioeconomic inequality as it can significantly show the income and wealth distribution within and among countries."),
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
                    LinkText('https://sdgs.un.org/goals/goal10'),
                    LinkText('https://unric.org/de/17ziele/sdg-10/'),
                    LinkText('https://www.bmz.de/de/agenda-2030/sdg-10'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/inequality/'),
                    LinkText(
                        'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/weniger-ungleichheiten-1592836'),
                  ],
                ),
                const GoBackButton().build(context),
              ],
            )),
      ),
    );
  }
}
