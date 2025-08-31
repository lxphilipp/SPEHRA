import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

/// Abstract class for handling authentication-related remote data operations.
abstract class AuthRemoteDataSource {
  /// Stream of authentication state changes from Firebase.
  Stream<fb_auth.User?> get firebaseAuthStateChanges;

  /// Gets the current Firebase user.
  Future<fb_auth.User?> getCurrentFirebaseUser();

  /// Signs in a user with email and password.
  Future<fb_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password.
  Future<fb_auth.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs out the current user.
  Future<void> signOut();

  /// Creates a user document in Firestore.
  Future<void> createUserDocument(UserModel userModel);

  /// Updates the user's presence status in Firestore.
  Future<void> updateUserPresence({
    required String userId,
    required bool isOnline,
    DateTime? lastActiveAt,
  });
}

/// Implementation of [AuthRemoteDataSource] using Firebase.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});

  @override
  Stream<fb_auth.User?> get firebaseAuthStateChanges => firebaseAuth.authStateChanges();

  @override
  Future<fb_auth.User?> getCurrentFirebaseUser() async => firebaseAuth.currentUser;

  @override
  Future<fb_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<fb_auth.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createUserDocument(UserModel userModel) async {
    try {
      if (userModel.id == null || userModel.id!.isEmpty) {
        throw Exception("User ID is missing in UserModel for createUserDocument");
      }
      await firestore.collection('users').doc(userModel.id).set(userModel.toMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserPresence({
    required String userId,
    required bool isOnline,
    DateTime? lastActiveAt,
  }) async {
    try {
      final Map<String, dynamic> dataToUpdate = {
        'online': isOnline,
      };
      if (lastActiveAt != null) {
        dataToUpdate['lastActiveAt'] = Timestamp.fromDate(lastActiveAt);
      } else {
        if (!isOnline) {
          dataToUpdate['lastActiveAt'] = FieldValue.serverTimestamp();
        }
      }

      await firestore.collection('users').doc(userId).update(dataToUpdate);
    } catch (e) {
      AppLogger.error("Error updating user presence for $userId: $e");
      rethrow;
    }
  }

}