import 'package:flutter/material.dart';
import 'package:flutter_sdg/homepage/homepage.dart';

class LoginLayout extends StatelessWidget {
  final Widget body;

  const LoginLayout({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: body,
      backgroundColor: const Color(0xff040324),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: buildAppBarTitle(context),
      backgroundColor: const Color(0xff040324),
      elevation: 0,
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    double logoHeight = AppBar().preferredSize.height - 16.0;

    return SizedBox(
      height: logoHeight,
      width: MediaQuery.of(context).size.width,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/logo/sphera_logo.png',
          height: logoHeight,
        ),
      ),
    );
  }

  void navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const HomePageScreen(),
    ));
  }
}
