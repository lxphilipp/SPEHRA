import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal3 extends StatelessWidget {
  const Goal3({super.key});

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
                                AssetImage('assets/icons/17_SDG_Icons/3.png'))),
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
                          fontSize: 35),
                      "Good Health and Well-being"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "SDG 3 aims to achieve universal health coverage and equitable access of healthcare services to all men and women. It proposes to end the preventable death of newborns, infants and children under five (child mortality) and end epidemics.Good health is essential to sustainable development and the 2030 Agenda. It focuses on broader economic and social inequalities, urbanization, climate crisis, and the continuing burden of HIV and other infectious diseases, while not forgetting emerging challenges such as non-communicable diseases. Considering the global pandemic of COVID-19, there is a need to give significant attention to the realization of good health and well-being on a global scale. "),
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
                    LinkText('https://sdgs.un.org/goals/goal3'),
                    LinkText(
                        'https://unstats.un.org/sdgs/report/2022/Goal-03/'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/health/'),
                    LinkText('https://www.who.int/ '),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                //const GoBackButton().build(context),
                Center(child: GoBackButton().build(context)),
              ],
            )),
      ),
    );
  }
}
