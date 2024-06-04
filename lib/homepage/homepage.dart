import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/homepage_layout.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sdg/17goals/goal1.dart';
import 'package:flutter_sdg/17goals/goal10.dart';
import 'package:flutter_sdg/17goals/goal11.dart';
import 'package:flutter_sdg/17goals/goal12.dart';
import 'package:flutter_sdg/17goals/goal13.dart';
import 'package:flutter_sdg/17goals/goal14.dart';
import 'package:flutter_sdg/17goals/goal15.dart';
import 'package:flutter_sdg/17goals/goal16.dart';
import 'package:flutter_sdg/17goals/goal17.dart';
import 'package:flutter_sdg/17goals/goal2.dart';
import 'package:flutter_sdg/17goals/goal3.dart';
import 'package:flutter_sdg/17goals/goal4.dart';
import 'package:flutter_sdg/17goals/goal5.dart';
import 'package:flutter_sdg/17goals/goal6.dart';
import 'package:flutter_sdg/17goals/goal7.dart';
import 'package:flutter_sdg/17goals/goal8.dart';
import 'package:flutter_sdg/17goals/goal9.dart';
import '../intro/background_image.dart';
import '../providers/auth_provider.dart';
import 'challenge_details.dart';
import 'challenges.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageLayout(body: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Color getCategoryColor(String category) {
    switch (category) {
      case 'goal1':
        return const Color(0xffE5243B);
      case 'goal2':
        return const Color(0xffDDA63A);
      case 'goal3':
        return const Color(0xff4c9F38);
      case 'goal4':
        return const Color(0xffC5192D);
      case 'goal5':
        return const Color(0xffFF3A21);
      case 'goal6':
        return const Color(0xff26BDE2);
      case 'goal7':
        return const Color(0xffFFC30B);
      case 'goal8':
        return const Color(0xffA21942);
      case 'goal9':
        return const Color(0xffFD6925);
      case 'goal10':
        return const Color(0xffDD1367);
      case 'goal11':
        return const Color(0xffFD9D24);
      case 'goal12':
        return const Color(0xffBF8B2E);
      case 'goal13':
        return const Color(0xff3F7E44);
      case 'goal14':
        return const Color(0xff0A97D9);
      case 'goal15':
        return const Color(0xff56C02B);
      case 'goal16':
        return const Color(0xff00689D);
      case 'goal17':
        return const Color(0xff19486A);

      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    List<Widget> imageList = [
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal1())),
        child: Image.asset('assets/icons/17_SDG_Icons/1.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal2())),
        child: Image.asset('assets/icons/17_SDG_Icons/2.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal3())),
        child: Image.asset('assets/icons/17_SDG_Icons/3.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal4())),
        child: Image.asset('assets/icons/17_SDG_Icons/4.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal5())),
        child: Image.asset('assets/icons/17_SDG_Icons/5.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal6())),
        child: Image.asset('assets/icons/17_SDG_Icons/6.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal7())),
        child: Image.asset('assets/icons/17_SDG_Icons/7.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal8())),
        child: Image.asset('assets/icons/17_SDG_Icons/8.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal9())),
        child: Image.asset('assets/icons/17_SDG_Icons/9.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal10())),
        child: Image.asset('assets/icons/17_SDG_Icons/10.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal11())),
        child: Image.asset('assets/icons/17_SDG_Icons/11.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal12())),
        child: Image.asset('assets/icons/17_SDG_Icons/12.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal13())),
        child: Image.asset('assets/icons/17_SDG_Icons/13.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal14())),
        child: Image.asset('assets/icons/17_SDG_Icons/14.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal15())),
        child: Image.asset('assets/icons/17_SDG_Icons/15.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal16())),
        child: Image.asset('assets/icons/17_SDG_Icons/16.png'),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Goal17())),
        child: Image.asset('assets/icons/17_SDG_Icons/17.png'),
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const BackgroundImage(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          const Color(0xff040324).withOpacity(1.0),
                          const Color(0xff040324).withOpacity(1.0),
                          const Color(0xff040324).withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          const Color(0xff040324).withOpacity(0.8),
                          const Color(0xff040324).withOpacity(0.8),
                          const Color(0xff040324).withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 40, bottom: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Welcome, \n${authProvider.userData.name}',
                            style: const TextStyle(
                                fontFamily: 'OswaldRegular',
                                color: Colors.white,
                                fontSize: 30),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: TextStyle(
                                fontFamily: 'OswaldLight',
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(width: 50, child: imageList[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("To do", style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ChallengesScreen(initialTabIndex: 1),
                        ),
                      );
                    },
                    child: const Text("See all",
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white)),
                  ),
                ]),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(authProvider.currentUserUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var ongoingTasks = snapshot.data!.exists
                        ? snapshot.data!.get('ongoingTasks') as List
                        : [];

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('challenges')
                          .snapshots(),
                      builder: (context, challengesSnapshot) {
                        if (!challengesSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        var allChallenges = challengesSnapshot.data!.docs;

                        if (allChallenges.isEmpty) {
                          return const Text('No challenges found.',
                              style: TextStyle(color: Colors.white));
                        }
                        var challengesToShow = <QueryDocumentSnapshot>[];

                        challengesToShow = allChallenges
                            .where((challengeDocument) =>
                                ongoingTasks.contains(challengeDocument.id))
                            .toList();

                        return Column(
                          children:
                              challengesToShow.take(3).map((challengeDocument) {
                            var challengeData = challengeDocument.exists
                                ? challengeDocument.data()
                                    as Map<String, dynamic>
                                : {};
                            var category = challengeData.containsKey('category')
                                ? challengeData['category']
                                : '';
                            Color circleColor = Colors.white;

                            circleColor = getCategoryColor(category[0]);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xff38344c),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChallengeDetailsScreen(
                                        title: challengeData['title'],
                                        description:
                                            challengeData['description'],
                                        task: challengeData['task'],
                                        points: challengeData['points'],
                                        category:
                                            (challengeData['category'] as List)
                                                .map((item) => item.toString())
                                                .toList()
                                                .cast<String>(),
                                        challengeId: challengeDocument.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    leading: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: circleColor,
                                      ),
                                    ),
                                    title: Text(challengeData['title'],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    subtitle: Text(
                                      challengeData['difficulty'].toString(),
                                      style: const TextStyle(
                                          fontFamily: 'Oswaldlight',
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white),
                                    ),
                                    trailing: Column(
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Image.asset(
                                              'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche 1.png'),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          challengeData['points'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'OswaldLight'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Completed",
                      style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ChallengesScreen(initialTabIndex: 2),
                        ),
                      );
                    },
                    child: const Text("See all",
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white)),
                  ),
                ]),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(authProvider.currentUserUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    var completedTasks =
                        snapshot.data!.get('completedTasks') as List;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('challenges')
                          .snapshots(),
                      builder: (context, challengesSnapshot) {
                        if (!challengesSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        var allChallenges = challengesSnapshot.data!.docs;
                        var challengesToShow = <QueryDocumentSnapshot>[];

                        challengesToShow = allChallenges
                            .where((challengeDocument) =>
                                completedTasks.contains(challengeDocument.id))
                            .toList();

                        return Column(
                          children:
                              challengesToShow.take(3).map((challengeDocument) {
                            var challengeData = challengeDocument.data()
                                as Map<String, dynamic>;
                            var category = challengeData['category'];
                            Color circleColor = Colors.white;

                            circleColor = getCategoryColor(category[0]);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xff38344c),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChallengeDetailsScreen(
                                        title: challengeData['title'],
                                        description:
                                            challengeData['description'],
                                        task: challengeData['task'],
                                        points: challengeData['points'],
                                        category:
                                            (challengeData['category'] as List)
                                                .map((item) => item.toString())
                                                .toList()
                                                .cast<String>(),
                                        challengeId: challengeDocument.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    leading: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: circleColor,
                                      ),
                                    ),
                                    title: Text(challengeData['title'],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    subtitle: Text(
                                      challengeData['difficulty'].toString(),
                                      style: const TextStyle(
                                          fontFamily: 'Oswaldlight',
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white),
                                    ),
                                    trailing: Column(
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Image.asset(
                                              'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche 1.png'),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          challengeData['points'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'OswaldLight'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
