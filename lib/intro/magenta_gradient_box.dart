import 'package:flutter/material.dart';
import 'package:flutter_sdg/intro/orange_gradient_box.dart';
import 'package:flutter_sdg/layout/intro_layout.dart';
import '../core/navigation/route_transitions.dart';

class MagentaGradientBoxScreen extends StatelessWidget {
  const MagentaGradientBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          RouteTransitions.createSlideTransitionRoute(
            const OrangeGradientBoxScreen(),
          ),
        );
      },
      child: const IntroLayout(
        body: MagentaGradientBox(),
      ),
    );
  }
}

class MagentaGradientBox extends StatelessWidget {
  const MagentaGradientBox({super.key});

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
          _buildChallengesText(),
          _buildDescriptionText(),
          _buildGotItText(),
        ],
      ),
    );
  }

  static final List<Color> _gradientColors = [
    const Color(0xffDD1367).withOpacity(1.0),
    const Color(0xffDD1367).withOpacity(1.0),
    const Color(0xffDD1367).withOpacity(0.0),
  ];

  static const List<double> _gradientStops = [0.0, 0.5, 1.0];

  static const TextStyle _textStyle = TextStyle(
    fontFamily: 'OswaldLight',
    color: Colors.white,
  );

  Widget _buildChallengesText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Text(
        'Challenges',
        style: _textStyle.copyWith(fontSize: 21),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      child: Text(
        'Zero dolor sit amet, consectetur adipiscing elit, sed do eiusmod. dolor sit amet, con',
        style: _textStyle.copyWith(fontSize: 19),
      ),
    );
  }

  Widget _buildGotItText() {
    return Center(
      child: Text(
        'Got it',
        style: _textStyle.copyWith(fontSize: 30),
      ),
    );
  }
}
