import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/delete_button_layout.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../models/user_data.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({Key? key}) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  // Global key for the form to handle form validation and submission
  final _formKey = GlobalKey<FormState>();

  // Controllers for various form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _studyFieldController = TextEditingController();
  final _schoolController = TextEditingController();

  // Holds the selected image
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    // Initialize the state with user data
    final authProvider =
        Provider.of<MYAuthProvider>(context, listen: false); // تغيييييييييييير
    final userData = authProvider.userData;

    authProvider.fetchUserDataFromFirestore(); // Fetch user data from Firestore
    _nameController.text = userData.name!; //
    _ageController.text = userData.age.toString();
    _studyFieldController.text = userData.studyField!; //
    _schoolController.text = userData.school!;
  }

  // Function to open the image picker
  Future<void> _openImagePicker() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MYAuthProvider>(context); //تغيييييييييير
    final userData = authProvider.userData;

    // Set the form field values based on user data
    _nameController.text = userData.name!; //
    _ageController.text = userData.age.toString();
    _studyFieldController.text = userData.studyField!; //
    _schoolController.text = userData.school!; //

    // Determine the avatar image provider based on the selected image or user's existing image URL
    ImageProvider? avatarImageProvider;
    if (_selectedImage != null) {
      avatarImageProvider = FileImage(_selectedImage!);
    } else if (userData.imageURL != null) {
      avatarImageProvider = NetworkImage(userData.imageURL!);
    }

    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OswaldLight',
          ),
        ),
        backgroundColor: const Color(0xff040324),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Associate the form key with the form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Allow user to tap to open the image picker
                GestureDetector(
                  onTap: _openImagePicker,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: avatarImageProvider,
                    child: _selectedImage == null && userData.imageURL == null
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Display the user's email
                Text('Email: ${authProvider.currentUserEmail}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'OswaldLight',
                    )),
                const SizedBox(height: 20),

                // Text form fields for user input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontFamily: 'OswaldLight')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Age',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontFamily: 'OswaldLight')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _studyFieldController,
                  decoration: const InputDecoration(
                      labelText: 'Study Field',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontFamily: 'OswaldLight')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a study field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                      labelText: 'School',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontFamily: 'OswaldLight')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a school';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Button to save changes
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3BBE6B),
                    ),
                    onPressed: () async {
                      // Prepare updated user data based on form input
                      final updatedUserData = UserData(
                        name: _nameController.text,
                        age: int.parse(_ageController.text),
                        studyField: _studyFieldController.text,
                        school: _schoolController.text,
                        level: userData.level,
                        points: userData.points,
                        ongoingTasks: userData.ongoingTasks,
                        completedTasks: userData.completedTasks,
                      );

                      final uid = authProvider.currentUserUid;

                      if (_selectedImage != null) {
                        // Handle image upload
                        String? oldImageURL = userData.imageURL;
                        if (oldImageURL != null) {
                          try {
                            await FirebaseStorage.instance
                                .refFromURL(oldImageURL)
                                .delete();
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An error occurred: $error'),
                              ),
                            );
                          }
                        }

                        final storageRef = FirebaseStorage.instance
                            .ref()
                            .child('profile_images')
                            .child('$uid.jpg');
                        await storageRef.putFile(_selectedImage!);

                        final imageURL = await storageRef.getDownloadURL();
                        updatedUserData.imageURL = imageURL;
                      } else {
                        updatedUserData.imageURL = userData.imageURL;
                      }

                      // Update user data in Firestore and provider
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set(updatedUserData.toMap())
                          .then((_) {
                        authProvider.updateUserData(updatedUserData);
                        Navigator.pop(context);
                      }).catchError((error) {});
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'OswaldLight',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: DeleteButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
