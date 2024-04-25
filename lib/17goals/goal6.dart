import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';

class Goal6 extends StatelessWidget {
  const Goal6({super.key});

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
                              AssetImage('assets/icons/17_SDG_Icons/6.png'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 45),
                    "Clean water and sanitation"),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    " \"Clean water and sanitation for all\". It is one of the 17 Sustainable Development Goals established by the United Nations General Assembly in 2015. According to the United Nations, the goal is to: \"Ensure availability and sustainable management of water and sanitation for all.\"Like the others, this Sustainable Development goal is interrelated with the other SDGs. For example, access to clean water will improve o health and wellbeing, leading to a progress in SDG3"),
                const GoBackButton().build(context),
              ],
            )),
      ),
    );
  }
}
