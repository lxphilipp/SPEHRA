import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal13 extends StatelessWidget {
  const Goal13({super.key});

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
                                'assets/icons/17_SDG_Icons/13.png'))),
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
                      "Climate Action"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "SDG 13 intends to take urgent action in order to combat climate change and its impacts. Climate change threatens people with increased flooding, extreme heat, increased food and water scarcity, more disease, and economic loss. Human migration and conflict can also be a result. Many climate change impacts are already felt at the current 1.2 °C (2.2 °F) level of warming. Additional warming will increase these impacts and can trigger tipping points, such as the melting of the Greenland ice sheet."),
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
                    LinkText('https://sdgs.un.org/goals/goal13'),
                    LinkText('https://unric.org/de/17ziele/sdg-13/'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/climate-change/'),
                    LinkText(
                        'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/weltweit-klimaschutz-umsetzen-181812'),
                    LinkText('https://sdgs.un.org/goals/goal13'),
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
