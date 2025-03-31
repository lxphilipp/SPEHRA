import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/homepage_layout.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:provider/provider.dart';
import '../intro/background_image.dart';
import '../providers/auth_provider.dart';

class ChallengeDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String task;
  final int points;
  final List<String> category;
  final String challengeId;
  final bool isLiked = false;

  const ChallengeDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.task,
    required this.points,
    required this.category,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return HomePageLayout(
        body: ChallengeDetails(
      title: title,
      description: description,
      task: task,
      points: points,
      category: category,
      challengeId: challengeId,
    ));
  }
}

class ChallengeDetails extends StatelessWidget {
  final String title;
  final String description;
  final String task;
  final int points;
  final List<String> category;
  final String challengeId;

  const ChallengeDetails({
    super.key,
    required this.title,
    required this.description,
    required this.task,
    required this.points,
    required this.category,
    required this.challengeId,
  });

  // Function to remove a challenge from ongoing tasks
  Future<void> removeFromOngoingTasks(BuildContext context) async {
    // Get necessary instances
    final authProvider =
        Provider.of<MYAuthProvider>(context, listen: false); // تغييييييير
    final navigator = Navigator.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    // Retrieve user's ongoing tasks
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authProvider.currentUserUid)
        .get();

    final userData = UserData.fromMap(userDoc.data()!);

    // Remove challenge from ongoing tasks if present
    if (userData.ongoingTasks!.contains(challengeId)) {
      final updatedOngoingTasks = userData.ongoingTasks!.toList()
        ..remove(challengeId);

      // Update user's ongoing tasks
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUserUid)
          .update({
        'ongoingTasks': updatedOngoingTasks,
      });

      // Show snackbar indicating the task has been removed
      snackbar.showSnackBar(
        const SnackBar(
          content: Text('Task removed from Ongoing Tasks'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait for a moment and then update user data and navigate back
      await Future.delayed(const Duration(seconds: 2));
      authProvider.fetchUserDataFromFirestore();
      navigator.pop();
    }
  }

  // Function to fetch challenge points from Firestore
  Future<int> fetchChallengePoints(String challengeId) async {
    final challengeDoc = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .get();

    // If the challenge document exists, retrieve the points from it
    if (challengeDoc.exists) {
      final challengeData = challengeDoc.data() as Map<String, dynamic>;
      return challengeData['points'] ??
          0; // Return points, default to 0 if not found
    }

    return 0; // Return 0 points if the challenge document doesn't exist
  }

// Function to add a challenge to completed tasks
  Future<void> addToCompletedTasks(BuildContext context) async {
    final authProvider =
        Provider.of<MYAuthProvider>(context, listen: false); // تغيييييييير
    final navigator = Navigator.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    // List of level thresholds and corresponding levels
    List<int> levelThresholds = [0, 2000, 3000, 4000];
    List<int> levels = [1, 2, 3, 4];

    // Retrieve user data from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authProvider.currentUserUid)
        .get();

    final userData = UserData.fromMap(userDoc.data()!);

    // If the challenge is in ongoing tasks, update completed tasks
    if (userData.ongoingTasks!.contains(challengeId)) {
      final updatedOngoingTasks = userData.ongoingTasks!.toList()
        ..remove(challengeId);
      final updatedCompletedTasks = userData.completedTasks!.toList()
        ..add(challengeId);

      // Update user's ongoing and completed tasks
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUserUid)
          .update({
        'ongoingTasks': updatedOngoingTasks,
        'completedTasks': updatedCompletedTasks,
      });

      // Calculate total points based on completed tasks
      int totalPoints = 0;
      for (String taskId in updatedCompletedTasks) {
        int taskPoints = await fetchChallengePoints(taskId);
        totalPoints += taskPoints;
      }

      // Update user's points
      authProvider.updateUserPoints(totalPoints);

      // Determine user's level based on total points and level thresholds
      int userLevel = 1;
      for (int i = 0; i < levelThresholds.length; i++) {
        if (totalPoints >= levelThresholds[i]) {
          userLevel = levels[i];
        } else {
          break;
        }
      }

      // Update user's points and level
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUserUid)
          .update({
        'points': totalPoints,
        'level': userLevel,
      });

      // Update user's level in the authProvider
      authProvider.updateUserLevel(userLevel);

      // Show snackbar indicating task completion and navigate back after a delay
      snackbar.showSnackBar(
        const SnackBar(
          content: Text('Task marked as Completed'),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      navigator.pop();
    }
  }

  Widget _buildCategoryImage(int index, String imagePath) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Image.asset(imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtain the authentication provider, navigator, and snackbar for later use
    final authProvider = Provider.of<MYAuthProvider>(context); // تغيييييييييير
    final navigator = Navigator.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    // Function to add the current challenge to ongoing tasks
    Future<void> addToOngoingTasks() async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUserUid)
          .update({
        'ongoingTasks': FieldValue.arrayUnion([challengeId]),
      });
    }

    // Function to check if the challenge is already completed
    Future<bool> isChallengeCompleted() async {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUserUid)
          .get();

      final userData = UserData.fromMap(userDoc.data()!);
      return userData.completedTasks!.contains(challengeId);
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

    int categoryIndex = -1;

    // Determine the index of the current category plus I am not sure if deleting this code will affect the app
    for (int i = 0; i < categoryNames.length; i++) {
      if (categoryNames[i] == category[0]) {
        categoryIndex =
            categoryNames.indexWhere((element) => category.contains(element));
        break;
      }
    }

    String imagePath = 'assets/icons/17_SDG_Icons/${categoryIndex + 1}.png';

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
                          _buildCategoryImage(categoryIndex, imagePath),
                          const SizedBox(height: 10),
                          Text(
                            'Challenge $title',
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
          Padding(
            padding:
                const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                      fontFamily: 'OswaldRegular',
                      color: Colors.white,
                      fontSize: 15),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                      fontFamily: 'OswaldLight',
                      color: Colors.white,
                      fontSize: 15),
                ),
                const SizedBox(height: 50),
                const SizedBox(height: 10),
                const Text(
                  'Task',
                  style: TextStyle(
                      fontFamily: 'OswaldRegular',
                      color: Colors.white,
                      fontSize: 15),
                ),
                const SizedBox(height: 10),
                Text(
                  task,
                  style: const TextStyle(
                      fontFamily: 'OswaldLight',
                      color: Colors.white,
                      fontSize: 15),
                ),
                const SizedBox(height: 50),
                const SizedBox(height: 10),
                Text(
                  'Points: $points', // Display the points value
                  style: const TextStyle(
                      fontFamily: 'OswaldRegular',
                      color: Colors.white,
                      fontSize: 15),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(authProvider.currentUserUid)
                          .get();

                      final userData = UserData.fromMap(userDoc.data()!);

                      if (await isChallengeCompleted()) {
                        snackbar.showSnackBar(
                          const SnackBar(
                            content: Text('Challenge already completed'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (userData.ongoingTasks!.contains(challengeId)) {
                        snackbar.showSnackBar(
                          const SnackBar(
                            content:
                                Text('Challenge is already in Ongoing Tasks'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        await addToOngoingTasks();

                        snackbar.showSnackBar(
                          const SnackBar(
                            content: Text('Added to Ongoing Tasks'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        await Future.delayed(const Duration(seconds: 4));

                        navigator.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Add to Ongoing'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      isChallengeCompleted().then((isCompleted) {
                        if (isCompleted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Challenge already completed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          addToCompletedTasks(context);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            child: ElevatedButton(
              onPressed: () {
                isChallengeCompleted().then((isCompleted) {
                  if (isCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Challenge already completed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    removeFromOngoingTasks(context);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove from Ongoing'),
            ),
          ),
        ],
      ),
    );
  }
}
