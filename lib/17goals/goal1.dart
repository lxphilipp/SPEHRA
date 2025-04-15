// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/link.dart';

class Goal1 extends StatelessWidget {
  const Goal1({super.key});

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
                              AssetImage('assets/icons/17_SDG_Icons/1.png'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 45),
                    "No Poverty"),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    'The 2030 Agenda acknowledges that eradicating poverty in all its forms and dimensions, including extreme poverty, is the greatest global challenge and an indispensable requirement for sustainable development. The first Sustainable Development Goal aims to End poverty in all its forms everywhere. Its seven associated targets aims, among others, to eradicate extreme poverty for all people everywhere, reduce at least by half the proportion of men, women and children of all ages living in poverty, and implement nationally appropriate social protection systems and measures for all, including floors, and by 2030 achieve substantial coverage of the poor and the vulnerable.'),
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
                    LinkText('https://sdgs.un.org/goals/goal1'),
                    LinkText(
                        'https://www.bmuv.de/themen/nachhaltigkeit/nachhaltigkeitsziele-sdgs/sdg-1-keine-armut'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/poverty/'),
                  ],
                ),
                const GoBackButton().build(context),
              ],
            )),
      ),
    );
  }
}
