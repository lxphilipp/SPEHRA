import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/home/chat_home_screen.dart';
import 'package:flutter_sdg/Chat/home/contact_home_screen.dart';
import 'package:flutter_sdg/Chat/home/group_home_screen.dart';
import 'package:flutter_sdg/Chat/home/userList_home_screen.dart';
import 'package:iconsax/iconsax.dart';

class LayoutApp extends StatefulWidget {
  const LayoutApp({
    super.key,
  });

  @override
  State<LayoutApp> createState() => _LayoutAppState();
}

class _LayoutAppState extends State<LayoutApp> {
  TextEditingController emailcon = TextEditingController();

  int currentIndex = 0;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [];
    return Scaffold(
      // backgroundColor: const Color(0xff040324)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: PageView(
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        controller: pageController,
        children: const [
          ChatHomeScreen(),
          GroupHomeScreen(),
          //ContactHomeScreen(),
          UserlistHomeScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
          elevation: 0,
          selectedIndex: currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              currentIndex = value;
              pageController.jumpToPage(value);
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.message), label: 'Chat'),
            NavigationDestination(icon: Icon(Iconsax.messages), label: 'Group'),
            //NavigationDestination(icon: Icon(Iconsax.user), label: 'Contact'),
            NavigationDestination(
                icon: Icon(Icons.favorite), label: 'Favorite'),
          ]),
    );
  }
}
