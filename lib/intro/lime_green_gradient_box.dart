import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/intro_layout.dart';
import '../login/signin.dart';
import '../transistions/route_transitions.dart';

class LimeGreenGradientBoxScreen extends StatelessWidget {
  const LimeGreenGradientBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          RouteTransitions.createSlideTransitionRoute(const SignInScreen()),
        );
      },
      child: IntroLayout(
        body: LimeGreenGradientBox(),
      ),
    );
  }
}

class LimeGreenGradientBox extends StatelessWidget {
  LimeGreenGradientBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: _gradientColors,
          stops: _gradientStops,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBattlesText(),
          _buildDescriptionText(),
          _buildGetStartedText(),
        ],
      ),
    );
  }

  final List<Color> _gradientColors = [
    const Color(0xff56C02B).withOpacity(1.0),
    const Color(0xff56C02B).withOpacity(1.0),
    const Color(0xff56C02B).withOpacity(0.0),
  ];

  final List<double> _gradientStops = [0.0, 0.5, 1.0];

  Widget _buildBattlesText() {
    return const Padding(
      padding: EdgeInsets.only(top: 40, bottom: 40, left: 20, right: 20),
      child: Text(
        'Battles',
        style: TextStyle(
          fontFamily: 'OswaldLight',
          color: Colors.white,
          fontSize: 21,
        ),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Text(
        'Zero dolor sit amet, consectetur adipiscing elit, sed do eiusmod. dolor sit amet, con',
        style: TextStyle(
          fontFamily: 'OswaldLight',
          color: Colors.white,
          fontSize: 19,
        ),
      ),
    );
  }

  Widget _buildGetStartedText() {
    return const Center(
      child: Text(
        'Get Started',
        style: TextStyle(
          fontFamily: 'OswaldLight',
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }
}
