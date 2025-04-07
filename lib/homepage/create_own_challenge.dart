import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sdg/layout/homepage_layout.dart';

class CreateOwnChallengesScreen extends StatelessWidget {
  final int? initialTabIndex;

  const CreateOwnChallengesScreen({Key? key, this.initialTabIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePageLayout(
        body: CreateOwnChallenges(initialTabIndex: initialTabIndex));
  }
}

class CreateOwnChallenges extends StatefulWidget {
  final int? initialTabIndex;

  const CreateOwnChallenges({Key? key, this.initialTabIndex}) : super(key: key);

  @override
  State<CreateOwnChallenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<CreateOwnChallenges> {
  List<int> _selectedCategoryIndices = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  String _selectedLevel = "Easy";
  List<String> _selectedCategories = [];
  @override
  void initState() {
    super.initState();
    _selectedLevel = "Easy";
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

  void _showSnackbarMessage(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _saveChallenge() async {
    List<String> categories = _selectedCategories;
    String title = _titleController.text;
    String description = _descriptionController.text;
    String task = _taskController.text;
    int points = int.tryParse(_pointsController.text) ?? 0;
    String level = _selectedLevel;

    if (categories.isEmpty ||
        title.isEmpty ||
        description.isEmpty ||
        task.isEmpty ||
        points == 0 ||
        level.isEmpty) {
      _showSnackbarMessage('Please fill in all required fields', Colors.red);
      return;
    }

    Map<String, dynamic> challengeData = {
      'category': categories,
      'title': title,
      'description': description,
      'task': task,
      'points': points,
      'difficulty': level,
    };

    final navigator = Navigator.of(context);

    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .add(challengeData);

      _showSnackbarMessage('Challenge saved successfully', Colors.green);
      await Future.delayed(const Duration(seconds: 4));
      navigator.pop();
    } catch (error) {
      _showSnackbarMessage('Error saving challenge: $error', Colors.red);
    }
  }

  Widget _buildLevelOption(String levelName) {
    bool isSelected = _selectedLevel == levelName;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedLevel = "";
          } else {
            _selectedLevel = levelName;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            levelName,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(int index, String imagePath) {
    bool isSelected = _selectedCategoryIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategoryIndices.remove(index);
            _selectedCategories.remove(categoryNames[index]);
          } else {
            _selectedCategoryIndices.add(index);
            _selectedCategories.add(categoryNames[index]);
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

  @override
  Widget build(BuildContext context) {
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
                          const ExpandableTextWidget(),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Category", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff38344c),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _selectedCategories
                        .join(", "), // Display the selected category text
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Title",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff38344c),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                TextField(
                  maxLines: null,
                  minLines: 1,
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff38344c),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Task",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                TextField(
                  maxLines: null,
                  minLines: 1,
                  controller: _taskController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter task",
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff38344c),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Points",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "Enter points",
                    hintStyle: const TextStyle(color: Colors.white),
                    fillColor: const Color(0xff38344c),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Level", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLevelOption("Easy"),
                    _buildLevelOption("Normal"),
                    _buildLevelOption("Advanced"),
                    _buildLevelOption("Experienced"),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ElevatedButton(
              onPressed: _saveChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Save Challenge",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableTextWidget extends StatefulWidget {
  const ExpandableTextWidget({Key? key}) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String fullText =
        'The challenges are about implementing the SDGs (Sustainable Development Goals) in everyday life. You can take part in challenges that have already been created and create your own challenges on the SDGs of your choice. You will need support for some of them and you can encourage your friends to take part using the chat function!';
    String previewText = fullText.substring(0, 100) + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded ? fullText : previewText,
          style: const TextStyle(
            fontFamily: 'OswaldLight',
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? 'Read less' : 'Read more',
            style: const TextStyle(
              color: Colors.green,
              decoration: TextDecoration.underline,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
