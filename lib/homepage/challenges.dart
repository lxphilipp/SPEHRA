import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/homepage_layout.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'challenge_details.dart';

class ChallengesScreen extends StatelessWidget {
  final int? initialTabIndex;

  const ChallengesScreen({Key? key, this.initialTabIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePageLayout(body: Challenges(initialTabIndex: initialTabIndex));
  }
}

class Challenges extends StatefulWidget {
  final int? initialTabIndex;

  const Challenges({Key? key, this.initialTabIndex}) : super(key: key);

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  int _selectedTab = 0;
  List<int> _selectedCategoryIndices = [];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex ?? 0;
  }

  List<String> categoryNames = [
    'goal1',
    'goal2',
    'goal3',
    'goal4',
    'goal5',
    'goal6',
    'goal7',
    'goal8',
    'goal9',
    'goal10',
    'goal11',
    'goal12',
    'goal13',
    'goal14',
    'goal15',
    'goal16',
    'goal17'
  ];

  Widget _buildCategoryImage(int index, String imagePath) {
    bool isSelected = _selectedCategoryIndices.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          //neue hinzugefügt wegen List<dynamic> error
          if (isSelected) {
            _selectedCategoryIndices.remove(index);
          } else {
            _selectedCategoryIndices.add(index);
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: Image.asset(imagePath),
          ),
        ],
      ),
    );
  }

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
    final authProvider = Provider.of<MYAuthProvider>(context); // تغيييييييييير

    List<Widget> imageList = [
      _buildCategoryImage(0, 'assets/icons/17_SDG_Icons/1.png'),
      _buildCategoryImage(1, 'assets/icons/17_SDG_Icons/2.png'),
      _buildCategoryImage(2, 'assets/icons/17_SDG_Icons/3.png'),
      _buildCategoryImage(3, 'assets/icons/17_SDG_Icons/4.png'),
      _buildCategoryImage(4, 'assets/icons/17_SDG_Icons/5.png'),
      _buildCategoryImage(5, 'assets/icons/17_SDG_Icons/6.png'),
      _buildCategoryImage(6, 'assets/icons/17_SDG_Icons/7.png'),
      _buildCategoryImage(7, 'assets/icons/17_SDG_Icons/8.png'),
      _buildCategoryImage(8, 'assets/icons/17_SDG_Icons/9.png'),
      _buildCategoryImage(9, 'assets/icons/17_SDG_Icons/10.png'),
      _buildCategoryImage(10, 'assets/icons/17_SDG_Icons/11.png'),
      _buildCategoryImage(11, 'assets/icons/17_SDG_Icons/12.png'),
      _buildCategoryImage(12, 'assets/icons/17_SDG_Icons/13.png'),
      _buildCategoryImage(13, 'assets/icons/17_SDG_Icons/14.png'),
      _buildCategoryImage(14, 'assets/icons/17_SDG_Icons/15.png'),
      _buildCategoryImage(15, 'assets/icons/17_SDG_Icons/16.png'),
      _buildCategoryImage(16, 'assets/icons/17_SDG_Icons/17.png'),
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
                          const Color.fromARGB(255, 5, 2, 78).withOpacity(0.8),
                          const Color.fromARGB(255, 5, 2, 78).withOpacity(0.8),
                          const Color(0xff040324).withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Challenges',
                            style: TextStyle(
                                fontFamily: 'OswaldRegular',
                                color: Colors.white,
                                fontSize: 30),
                          ),
                          SizedBox(height: 10),
                          Text(
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
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 80,
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
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedTab == 0
                            ? Colors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text("All challenges",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedTab == 1
                            ? Colors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text("On going",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 2;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedTab == 2
                            ? Colors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text("Completed",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
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
                    //hier ist irgendwo der Fehler
                    var completedTasks =
                        snapshot.data!.exists && snapshot.data!.data() != null
                            ? (snapshot.data!.get('completedTasks') as List)
                                .where((item) => item is String)
                                .map((item) => item?.toString() ?? '')
                                .toList()
                            : [];
                    var ongoingTasks =
                        snapshot.data!.exists && snapshot.data!.data() != null
                            ? (snapshot.data!.get('ongoingTasks') as List)
                                .where((item) => item is String)
                                .map((item) => item?.toString() ?? '')
                                .toList()
                            : [];

                    // StreamBuilder to fetch and display challenges based on the selected tab and category
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

                        // Filtering challenges based on selected tab and category
                        if (_selectedTab == 0) {
                          challengesToShow = allChallenges
                              .where((challengeDocument) =>
                                  !completedTasks
                                      .contains(challengeDocument.id) &&
                                  !ongoingTasks.contains(challengeDocument.id))
                              .toList();
                          if (!_selectedCategoryIndices.isEmpty) {
                            List<String> selectedCategories = [];
                            for (int i = 0;
                                i < _selectedCategoryIndices.length;
                                i++) {
                              selectedCategories.add(
                                  categoryNames[_selectedCategoryIndices[i]]);
                            }
                            challengesToShow = challengesToShow
                                .where((challengeDocument) =>
                                    challengeDocument['category'] ==
                                    selectedCategories)
                                .toList();
                          }
                        } else if (_selectedTab == 1) {
                          challengesToShow = allChallenges
                              .where((challengeDocument) =>
                                  ongoingTasks.contains(challengeDocument.id))
                              .toList();
                          if (!_selectedCategoryIndices.isEmpty) {
                            List<String> selectedCategories = [];
                            for (int i = 0;
                                i < _selectedCategoryIndices.length;
                                i++) {
                              selectedCategories.add(
                                  categoryNames[_selectedCategoryIndices[i]]);
                            }
                            challengesToShow = challengesToShow
                                .where((challengeDocument) =>
                                    challengeDocument['category'] ==
                                    selectedCategories)
                                .toList();
                          }
                        } else if (_selectedTab == 2) {
                          challengesToShow = allChallenges
                              .where((challengeDocument) =>
                                  completedTasks.contains(challengeDocument.id))
                              .toList();
                          if (!_selectedCategoryIndices.isEmpty) {
                            List<String> selectedCategories = [];
                            for (int i = 0;
                                i < _selectedCategoryIndices.length;
                                i++) {
                              selectedCategories.add(
                                  categoryNames[_selectedCategoryIndices[i]]);
                            }
                            challengesToShow = challengesToShow
                                .where((challengeDocument) =>
                                    challengeDocument['category'] ==
                                    selectedCategories)
                                .toList();
                          }
                        }

                        // Display the list of challenges
                        return Column(
                          children: challengesToShow.map((challengeDocument) {
                            var challengeData = challengeDocument.exists
                                ? challengeDocument.data()
                                    as Map<String, dynamic>
                                : {};
                            var categories =
                                challengeData.containsKey('category')
                                    ? challengeData['category']
                                    : '';
                            Color circleColor = Colors.white;

                            if (categories is List) {
                              circleColor = getCategoryColor(categories[0]);
                            } else if (categories is String) {
                              circleColor = getCategoryColor(categories);
                            }

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
                                        //hier ist das neue Problem
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
