import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_data.dart';

class MYAuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  UserData _userData = UserData(
    age: 0,
    name: '',
    school: '',
    studyField: '',
    imageURL: null,
  );

  // Getter for login status
  bool get isLoggedIn => _isLoggedIn;

  // Getter for user data
  UserData get userData => _userData;

  // Getter for user points
  int get userPoints => _userData.points!; // تغير

  // Getter for user level
  int get userLevel => _userData.level!; // تغير

  // User's email
  String _currentUserEmail = '';

  // User's UID
  String _currentUserUid = '';

  // Getter for current user's email
  String get currentUserEmail => _currentUserEmail;

  // Getter for current user's UID
  String get currentUserUid => _currentUserUid;

  // Method to handle user login
  void login(String email) {
    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchUserDataFromFirestore();
    notifyListeners();
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String Email, String Password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: Email,
        password: Password,
      );

      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Method to handle user logout
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Method to update user data
  void updateUserData(UserData newData) {
    _userData = newData;
    notifyListeners();
  }

  // Method to update user points
  void updateUserPoints(int newPoints) {
    _userData.points = newPoints;
    notifyListeners();
  }

  // Method to update user level
  void updateUserLevel(int level) {
    _userData.level = level;
    notifyListeners();
  }

  // Method to fetch user data from Firestore
  void fetchUserDataFromFirestore() async {
    final uid = currentUserUid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final userData = UserData.fromMap(userDoc.data()!);
      _userData = userData;
      notifyListeners();
    }
  }

  // Stream to listen to user data changes
  Stream<UserData> get userDataStream {
    final uid = currentUserUid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserData.fromMap(snapshot.data()!));
  }
}
