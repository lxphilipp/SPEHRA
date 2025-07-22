import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<fb_auth.User?> get firebaseAuthStateChanges;
  Future<fb_auth.User?> getCurrentFirebaseUser();
  Future<fb_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<fb_auth.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
  Future<void> createUserDocument(UserModel userModel);
  Future<void> updateUserPresence({
    required String userId,
    required bool isOnline,
    DateTime? lastActiveAt,
  });
}

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