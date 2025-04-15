import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/widgets/link_text.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
//import 'package:url_launcher/link.dart';

class Goal2 extends StatelessWidget {
  const Goal2({super.key});

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
                                AssetImage('assets/icons/17_SDG_Icons/2.png'))),
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
                      "Zero Hunger"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "End hunger, achieve food security and improved nutrition and promote sustainable agriculture. SDG 2 highlights the complex inter-linkages between food security, nutrition, rural transformation and sustainable agriculture. According to the United Nations, there are around 690 million people who are hungry, which accounts for slightly less than 10 percent of the world population. One in every nine people goes to bed hungry each night, including 20 million people currently at risk of famine in South Sudan, Somalia, Yemen and Nigeria."),
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
                    LinkText('https://sdgs.un.org/goals/goal2'),
                    LinkText('https://www.fao.org/zero-hunger'),
                    LinkText('https://www.wfp.org/'),
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
