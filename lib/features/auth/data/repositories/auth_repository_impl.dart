// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_failures.dart'; // <-- NEUER IMPORT
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  AuthFailure _handleFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    AppLogger.warning("AuthRepo: FirebaseAuthException (${e.code}): ${e.message}");
    switch (e.code) {
      case 'invalid-email':
        return const InvalidEmailFailure();
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return const InvalidCredentialsFailure();
      case 'email-already-in-use':
        return const EmailInUseFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'network-request-failed':
        return const NetworkFailure();
      default:
        return const UnknownAuthFailure();
    }
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await remoteDataSource.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return _mapFirebaseUserToUserEntity(credential.user);
    } on fb_auth.FirebaseAuthException catch (e) {
      // Wir fangen den Firebase-Fehler ab und werfen unseren eigenen, sauberen Fehler.
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      AppLogger.error("AuthRepo: Unerwarteter Fehler in signIn: $e", e);
      throw const UnknownAuthFailure();
    }
  }

  @override
  Future<UserEntity?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await remoteDataSource.registerWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw const UnknownAuthFailure();
      }

      final newUserModel = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        online: true,
        hasCompletedIntro: false,
      );

      await remoteDataSource.createUserDocument(newUserModel);
      return _mapFirebaseUserToUserEntity(firebaseUser, nameFromRegistration: name.trim());
    } on fb_auth.FirebaseAuthException catch (e) {
      // Auch hier wird der Fehler übersetzt und geworfen.
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      AppLogger.error("AuthRepo: Unerwarteter Fehler in register: $e", e);
      throw const UnknownAuthFailure();
    }
  }

  // -- Hilfsmethode (unverändert) --
  Future<UserEntity?> _mapFirebaseUserToUserEntity(fb_auth.User? firebaseUser, {String? nameFromRegistration}) async {
    if (firebaseUser == null) return null;
    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: nameFromRegistration ?? firebaseUser.displayName,
    );
  }

  // -- Restliche Methoden (unverändert) --
  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.firebaseAuthStateChanges.asyncMap((firebaseUser) async {
      return _mapFirebaseUserToUserEntity(firebaseUser);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = await remoteDataSource.getCurrentFirebaseUser();
    return _mapFirebaseUserToUserEntity(firebaseUser);
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    final currentUser = await remoteDataSource.getCurrentFirebaseUser();
    if (currentUser != null) {
      try {
        await remoteDataSource.updateUserPresence(
          userId: currentUser.uid,
          isOnline: false,
        );
      } catch (e) {
        AppLogger.error("AuthRepo: Fehler beim Aktualisieren der Präsenz vor dem Ausloggen.", e);
      }
    }
    await remoteDataSource.signOut();
  }
}