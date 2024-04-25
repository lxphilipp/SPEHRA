import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';

class Goal11 extends StatelessWidget {
  const Goal11({super.key});

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
                              AssetImage('assets/icons/17_SDG_Icons/11.png'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 45),
                    "Sustainable cities and communities"),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "SDG 11 addresses slums, human settlement management and planning, climate change mitigation and adaptation, and urban economies. There has been a rapid growth of mega-cities, especially in the developing world: In 1990, there were ten mega-cities with 10 million inhabitants or more, and in 2014, there were 28 mega-cities, home to a total of 453 million people. With regards to slums, data shows that \"828 million people live in slums today and most them are found in Eastern and South-Eastern Asia\"."),
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
