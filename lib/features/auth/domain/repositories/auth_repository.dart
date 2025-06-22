import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<bool> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> getCurrentUser();
}