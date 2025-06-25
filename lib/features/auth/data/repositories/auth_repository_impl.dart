import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart'; // Stelle sicher, dass dies dein aktualisiertes UserModel ist

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  Future<UserEntity?> _mapFirebaseUserToUserEntity(fb_auth.User? firebaseUser, {String? nameFromRegistration}) async {
    if (firebaseUser == null) return null;

    String? userName = nameFromRegistration ?? firebaseUser.displayName;

    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: userName, // Name kann hier null sein
    );
  }

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
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await remoteDataSource.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return _mapFirebaseUserToUserEntity(credential.user);
    } on fb_auth.FirebaseAuthException catch (e) {
      AppLogger.error("AuthRepo: FirebaseAuthException in signIn (${e.code}): ${e.message}", e, StackTrace.current);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error("AuthRepo: Unerwarteter Fehler in signIn: $e", e, stackTrace);
      return null;
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
        AppLogger.error("AuthRepo: Firebase user war null nach Registrierung.", null, StackTrace.current);
        return null;
      }

      // Erstelle UserModel mit den neuen DateTime Feldern
      final newUserModel = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        online: true,
        about: '',
        imageURL: null,
        pushToken: '',
        myUsers: [],
        age: null,
        studyField: "",
        school: "",
        level: 1,
        points: 0,
        ongoingTasks: [],
        completedTasks: [],
      );

      await remoteDataSource.createUserDocument(newUserModel);

      return _mapFirebaseUserToUserEntity(firebaseUser, nameFromRegistration: name.trim());
    } on fb_auth.FirebaseAuthException catch (e) {
      AppLogger.error("AuthRepo: FirebaseAuthException in register (${e.code}): ${e.message}", e, StackTrace.current);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error("AuthRepo: Unerwarteter Fehler in register: $e", e, stackTrace);
      return null;
    }
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e, stackTrace) {
      AppLogger.error("AuthRepo: Fehler in sendPasswordResetEmail: $e", e, stackTrace);
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final currentUser = await remoteDataSource.getCurrentFirebaseUser();
      if (currentUser != null) {
        try {
          await remoteDataSource.updateUserPresence(
            userId: currentUser.uid,
            isOnline: false,
          );
        } catch (e, stackTrace) {
          AppLogger.error("AuthRepo: Fehler beim Aktualisieren der Präsenz vor dem Ausloggen.", e, stackTrace);
        }
      }
    } finally {
      // Der finally-Block wird IMMER ausgeführt, egal ob der try-Block
      // erfolgreich war oder eine Exception geworfen hat.
      AppLogger.info("AuthRepo: Signing out user.");
      await remoteDataSource.signOut();
    }
  }
}