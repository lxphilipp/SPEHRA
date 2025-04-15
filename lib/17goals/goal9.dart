import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
// import 'package:url_launcher/link.dart';

class Goal9 extends StatelessWidget {
  const Goal9({super.key});

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
                                AssetImage('assets/icons/17_SDG_Icons/9.png'))),
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
                      "Industry, Innovation and Infrastructure"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "SDG 9 aims to build resilient infrastructure, promote sustainable industrialization and foster innovation. In 2019, it was reported that \"the intensity of global carbon dioxide emissions has declined by nearly one quarter since 2000, showing a general decoupling of carbon dioxide emissions from GDP growth\". Millions of people are still unable to access the internet due to cost, coverage, and other reasons. It is estimated that just 54% of the world's population are currently (in 2020) internet users."),
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
                    LinkText('https://sdgs.un.org/goals/goal9'),
                    LinkText(
                        'https://www.bmuv.de/themen/nachhaltigkeit/nachhaltigkeitsziele-sdgs/sdg-9-industrie-innovation-und-infrastruktur'),
                    LinkText('https://dashboards.sdgindex.org/rankings'),
                    LinkText('https://www.bmz.de/de/agenda-2030/sdg-9'),
                    LinkText(
                        'https://www.un.org/sustainabledevelopment/infrastructure-industrialization/'),
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
