import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';

class Goal16 extends StatelessWidget {
  const Goal16({super.key});

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
                              AssetImage('assets/icons/17_SDG_Icons/16.png'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 45),
                    "Peace, justice and strong institutions"),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "\"Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels\". SDG 16 addresses the need to promote peace and inclusive institutions. Areas of improvement include for example: reducing lethal violence, reducing civilian deaths in conflicts, and eliminating human trafficking."),
                const SizedBox(
                  height: 10,
                ),
                const GoBackButton().build(context),
              ],
            )),
      ),
    );
  }
}
