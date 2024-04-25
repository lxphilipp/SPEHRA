import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/backButton_layout.dart';
import 'package:flutter_sdg/layout/login_layout.dart';

class Goal12 extends StatelessWidget {
  const Goal12({super.key});

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
                              AssetImage('assets/icons/17_SDG_Icons/12.png'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 40),
                    "Responsible consumption and production"),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    style: TextStyle(
                        fontFamily: 'OswaldLight',
                        color: Colors.white,
                        fontSize: 18),
                    "SDG 12 is meant to ensure good use of resources, improve energy efficiency and sustainable infrastructure, provide access to basic services, create green and decent jobs, and ensure a better quality of life for all. Changes in consumption and production patterns can help to promote the decoupling of economic growth and human well-being from resource use and environmental impact. They can also trigger the transformations envisaged in global commitments on biodiversity, the climate, and sustainable development in general."),
                const GoBackButton().build(context),
              ],
            )),
      ),
    );
  }
}
