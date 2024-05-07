import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sdg/homepage/challenges.dart';
import 'package:flutter_sdg/homepage/create_own_challenge.dart';
import 'package:flutter_sdg/homepage/edit_profil.dart';
import 'package:flutter_sdg/homepage/homepage.dart';
import 'package:flutter_sdg/homepage/profile_stats.dart';
import 'package:flutter_sdg/homepage/userListPage.dart';
import 'package:flutter_sdg/layout/logoutButton_layout.dart';
import 'package:flutter_sdg/question/introduction1.dart';

class MenuDrawer extends StatefulWidget {
  @override
  MenuDrawerStare createState() => MenuDrawerStare();
}

class MenuDrawerStare extends State<MenuDrawer> {
  int _selectedItemIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: const Color(0xff040324),
        child: ListView(children: <Widget>[
          const SizedBox(height: 40),
          ExpansionTile(
            title: Text(
              'Home',
              style: TextStyle(
                fontFamily: 'OswaldRegular',
                fontSize: 30,
                color: _selectedItemIndex == 0
                    ? const Color(0xff3BBE6B)
                    : Colors.white,
              ),
            ),
            trailing:
                const Icon(Icons.arrow_drop_down, color: Color(0xff3BBE6B)),
            onExpansionChanged: (expanded) {
              setState(() {
                _selectedItemIndex = expanded ? 0 : -1;
              });
            },
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomePageScreen(),
                  ));
                },
                child: const ListTile(
                  title: Text('Homepage',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ChallengesScreen(),
                  ));
                },
                child: const ListTile(
                  title: Text('Challenges',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CreateOwnChallengesScreen(),
                  ));
                },
                child: const ListTile(
                  title: Text('Create own Challenge',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
              const ListTile(
                  title: Text('Find your Match',
                      style: TextStyle(fontSize: 15, color: Colors.white))),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'OswaldRegular',
                fontSize: 30,
                color: _selectedItemIndex == 1
                    ? const Color(0xff3BBE6B)
                    : Colors.white,
              ),
            ),
            trailing:
                const Icon(Icons.arrow_drop_down, color: Color(0xff3BBE6B)),
            onExpansionChanged: (expanded) {
              setState(() {
                _selectedItemIndex = expanded ? 1 : -1;
              });
            },
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const EditProfilPage(),
                  ));
                },
                child: const ListTile(
                  title: Text('Edit Profil',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ));
                },
                child: const ListTile(
                    title: Text('My Profile',
                        style: TextStyle(fontSize: 15, color: Colors.white))),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UserListPage()));
                },
                child: const ListTile(
                    title: Text('Chat',
                        style: TextStyle(fontSize: 15, color: Colors.white))),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => IntroductionPage(),
                  ));
                },
                child: const ListTile(
                    title: Text('Stats',
                        style: TextStyle(fontSize: 15, color: Colors.white))),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Infos',
              style: TextStyle(
                fontFamily: 'OswaldRegular',
                fontSize: 30,
                color: _selectedItemIndex == 2
                    ? const Color(0xff3BBE6B)
                    : Colors.white,
              ),
            ),
            trailing:
                const Icon(Icons.arrow_drop_down, color: Color(0xff3BBE6B)),
            onExpansionChanged: (expanded) {
              setState(() {
                _selectedItemIndex = expanded ? 2 : -1;
              });
            },
            children: const [
              ListTile(
                  title: Text('The 17 Goals',
                      style: TextStyle(fontSize: 15, color: Colors.white))),
              ListTile(
                  title: Text('News',
                      style: TextStyle(fontSize: 15, color: Colors.white))),
              ListTile(
                  title: Text('Voting',
                      style: TextStyle(fontSize: 15, color: Colors.white))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: LogoutButton(),
            ),
          )
        ]));
  }
}
