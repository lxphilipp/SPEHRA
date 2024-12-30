import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/homepage_layout.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'color_code.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageLayout(body: Profile());
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<MYAuthProvider>(context); // تغييييييييييييير
    final userData = authProvider.userData;

    String? profilPic = userData.imageURL;

    List<Widget> imageList = [
      Image.asset('assets/icons/sdg_named/1.jpg'),
      Image.asset('assets/icons/sdg_named/2.jpg'),
      Image.asset('assets/icons/sdg_named/3.jpg'),
      Image.asset('assets/icons/sdg_named/4.jpg'),
      Image.asset('assets/icons/sdg_named/5.jpg'),
      Image.asset('assets/icons/sdg_named/6.jpg'),
      Image.asset('assets/icons/sdg_named/7.jpg'),
      Image.asset('assets/icons/sdg_named/8.jpg'),
      Image.asset('assets/icons/sdg_named/9.jpg'),
      Image.asset('assets/icons/sdg_named/10.jpg'),
      Image.asset('assets/icons/sdg_named/11.jpg'),
      Image.asset('assets/icons/sdg_named/12.jpg'),
      Image.asset('assets/icons/sdg_named/13.jpg'),
      Image.asset('assets/icons/sdg_named/14.jpg'),
      Image.asset('assets/icons/sdg_named/15.jpg'),
      Image.asset('assets/icons/sdg_named/16.jpg'),
      Image.asset('assets/icons/sdg_named/17.jpg'),
    ];

    List<Color> categoryColors = [
      const Color(0xffE5243B),
      const Color(0xffDDA63A),
      const Color(0xff4c9F38),
      const Color(0xffC5192D),
      const Color(0xffFF3A21),
      const Color(0xff26BDE2),
      const Color(0xffFFC30B),
      const Color(0xffA21942),
      const Color(0xffFD6925),
      const Color(0xffDD1367),
      const Color(0xffFD9D24),
      const Color(0xffBF8B2E),
      const Color(0xff3F7E44),
      const Color(0xff0A97D9),
      const Color(0xff56C02B),
      const Color(0xff00689D),
      const Color(0xff19486A),
    ];

    List<String> goals = [
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

    Stream<List<PieChartSectionData>> fetchPieChartData() {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Stream<List<String>> completedTasksStream = firestore
          .collection('users')
          .doc(authProvider.currentUserUid)
          .snapshots()
          .map(
            (snapshot) =>
                List<String>.from(snapshot.data()?['completedTasks'] ?? []),
          );

      Stream<List<PieChartSectionData>> pieChartDataStream =
          completedTasksStream.asyncMap((completedTasks) async {
        List<int> a = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        List<Future<void>> futures = [];

        void fetchData(String completedTaskId) {
          futures.add(firestore
              .collection('challenges')
              .doc(completedTaskId)
              .get()
              .then((completedTaskSnapshot) {
            if (completedTaskSnapshot.exists) {
              String category = completedTaskSnapshot.data()!['category'];
              int categoryIndex = goals.indexOf(category);

              if (categoryIndex >= 0 && categoryIndex < a.length) {
                a[categoryIndex]++;
              }
            }
          }).catchError((error) {
            // ignore: avoid_print
            print('Error retrieving task $completedTaskId: $error');
          }));
        }

        for (var completedTaskId in completedTasks) {
          fetchData(completedTaskId);
        }

        await Future.wait(futures);

        List<PieChartSectionData> pieChartData = a.asMap().entries.map((entry) {
          int categoryIndex = entry.key;

          return PieChartSectionData(
            value: a[categoryIndex].toDouble(),
            color: categoryColors[categoryIndex],
          );
        }).toList();

        return pieChartData;
      });

      return pieChartDataStream;
    }

    // Build the profile content
    return ListView(
      padding: const EdgeInsets.only(top: 0),
      children: [
        // User profile header with background image and info
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (profilPic != null)
                Image.network(
                  profilPic,
                  fit: BoxFit.cover,
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        const Color(0xff040324).withOpacity(0.8),
                        const Color(0xff040324).withOpacity(0.8),
                        const Color(0xff040324).withOpacity(0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
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
                ),
              ),
            ],
          ),
        ),
        // Display user's basic information
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                    fontFamily: 'OswaldRegular',
                    color: Colors.white,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                'Name: ${authProvider.userData.name} \nAge: ${authProvider.userData.age} \nStudy Field: ${authProvider.userData.studyField} \nSchool: ${authProvider.userData.school} \nPoints: ${authProvider.userData.points} \nLevel ${authProvider.userData.level}',
                style: const TextStyle(
                    fontFamily: 'OswaldLight',
                    color: Colors.white,
                    fontSize: 15),
              ),
            ],
          ),
        ),
        // Display a placeholder for statistics section
        const SizedBox(height: 50),
        SizedBox(
          height: 100,
          child: Column(
            children: [
              Center(
                  child: Image.asset(
                      'assets/icons/allgemeineIcons/SDG-App-Iconset_Zeichenflaeche1Kopie8.png',
                      width: 50)),
              const Center(
                child: Text("stats", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
        StreamBuilder<List<PieChartSectionData>>(
          stream: fetchPieChartData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              List<PieChartSectionData>? pieChartData = snapshot.data;
              if (pieChartData != null) {
                return SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff38344c),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: PieChart(
                          PieChartData(
                            sections: pieChartData,
                            sectionsSpace: 0,
                            centerSpaceRadius: 60,
                            borderData: FlBorderData(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
            return Container();
          },
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(width: 90, child: imageList[index]),
              );
            },
          ),
        ),
        const ColorCode()
      ],
    );
  }
}
