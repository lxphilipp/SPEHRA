import '../entities/user_entity.dart';

/// Abstract class for handling authentication-related operations.
abstract class AuthRepository {

  /// Signs in a user with email and password.
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password.
  Future<UserEntity?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Sends a password reset email to the given email address.
  Future<bool> sendPasswordResetEmail({
    required String email,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Stream of authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Gets the current user.
  Future<UserEntity?> getCurrentUser();
}