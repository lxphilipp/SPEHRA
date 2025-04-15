import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal16 extends StatelessWidget {
  const Goal16({super.key});

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
                                'assets/icons/17_SDG_Icons/16.png'))),
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
                      "Peace, justice and strong institutions"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "\"Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels\". SDG 16 addresses the need to promote peace and inclusive institutions. Areas of improvement include for example: reducing lethal violence, reducing civilian deaths in conflicts, and eliminating human trafficking."),
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
                    LinkText('https://unric.org/de/17ziele/sdg-16/'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/peace-justice/'),
                    LinkText('https://sdgs.un.org/goals/goal16'),
                    LinkText(
                        'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/institutionen-foerdern-199866'),
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
