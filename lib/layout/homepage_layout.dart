import 'package:flutter/material.dart';
import 'package:flutter_sdg/homepage/homepage.dart';
import 'package:flutter_sdg/layout/menuDrawer_layout.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_data.dart';

class HomePageLayout extends StatefulWidget {
  final Widget body;

  const HomePageLayout({Key? key, required this.body}) : super(key: key);

  @override
  HomePageLayoutState createState() => HomePageLayoutState();
}

class HomePageLayoutState extends State<HomePageLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff040324),
        extendBodyBehindAppBar: true,
        appBar: buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: widget.body,
            ),
          ],
        ),
        endDrawer: Container(
          width: MediaQuery.of(context).size.width,
          child: MenuDrawer(),
        ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          buildAppBarLogo(context),
          const Spacer(),
          buildAppBarTitle(context),
          const Spacer(),
        ],
      ),
      iconTheme: const IconThemeData(color: Color(0xff3BBE6B)),
      backgroundColor: const Color(0xff040324),
      elevation: 0,
    );
  }

  Widget buildAppBarLogo(BuildContext context) {
    double logoHeight = AppBar().preferredSize.height - 16.0;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePageScreen()));
      },
      child: SizedBox(
        height: logoHeight,
        child: Image.asset(
          'assets/logo/Logo-Bild.png',
          height: logoHeight,
        ),
      ),
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    double logoHeight = AppBar().preferredSize.height - 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<MYAuthProvider>(
          // تغييييييير
          builder: (context, authProvider, _) {
            UserData? userData = authProvider.userData;
            // ignore: unnecessary_null_comparison
            if (userData != null) {
              String imagePath = '';

              switch (userData.level) {
                case 1:
                  imagePath = 'assets/icons/Level_Icons/1. Beginner.png';
                  break;
                case 2:
                  imagePath = 'assets/icons/Level_Icons/2. Intermediate.png';
                  break;
                case 3:
                  imagePath = 'assets/icons/Level_Icons/3. Advanced.png';
                  break;

                case 4:
                  imagePath = 'assets/icons/Level_Icons/4. Professional.png';
                  break;
                case 5:
                  imagePath = 'assets/icons/Level_Icons/5. Master.png';
                  break;
                case 6:
                  imagePath =
                      'assets/icons/Level_Icons/possible_intensification.png';
                  break;
              }

              return Column(
                children: [
                  SizedBox(
                    height: logoHeight,
                    child: Image.asset(
                      imagePath,
                      height: logoHeight,
                    ),
                  ),
                  Text(
                    'points: ${userData.points} | level: ${userData.level}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            } else {
              return const Text(
                'Error',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
