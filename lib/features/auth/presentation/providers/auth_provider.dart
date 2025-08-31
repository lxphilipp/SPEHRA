import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_failures.dart';
import '../../domain/usecases/get_auth_state_changes_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_user_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/sign_out_user_usecase.dart';
import '../../domain/usecases/send_password_reset_email_usecase.dart';

/// Manages the authentication state of the application.
///
/// This provider is the single source of truth for everything related to
/// user login, registration, and sign-out.
/// It listens to authentication state changes from the repository (via UseCase)
/// and informs dependent providers and the UI using `notifyListeners()`.
class AuthenticationProvider with ChangeNotifier {
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUserUseCase _signInUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final SignOutUserUseCase _signOutUserUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;

  UserEntity? _currentUser;
  bool _isLoading = true; 
  String? _errorMessage;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthenticationProvider({
    required GetAuthStateChangesUseCase getAuthStateChangesUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignInUserUseCase signInUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required SignOutUserUseCase signOutUserUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
  })  : _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _signInUserUseCase = signInUserUseCase,
        _registerUserUseCase = registerUserUseCase,
        _signOutUserUseCase = signOutUserUseCase,
        _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase {
    _listenToAuthStateChanges();
  }


  /// The currently signed-in user. `null` if nobody is signed in.
  UserEntity? get currentUser => _currentUser;

  /// Returns `true` if a user is signed in.
  bool get isLoggedIn => _currentUser != null;

  /// The ID of the currently signed-in user.
  String? get currentUserId => _currentUser?.id;

  /// The email of the currently signed-in user.
  String? get currentUserEmail => _currentUser?.email;

  /// Returns `true` while an asynchronous operation (e.g., login) is in progress.
  bool get isLoading => _isLoading;

  /// Contains an error message if an operation has failed.
  String? get errorMessage => _errorMessage;



  /// Starts the stream that listens for changes in the authentication state.
  void _listenToAuthStateChanges() {
    _authStateSubscription?.cancel(); 
    _authStateSubscription = _getAuthStateChangesUseCase().listen((userEntity) {
      _setLoading(false); 
      _updateCurrentUser(userEntity);
    });
  }

  /// Updates the internal user state and notifies all listeners.
  void _updateCurrentUser(UserEntity? user) {
    if (_currentUser != user) {
      _currentUser = user;
      notifyListeners();
    }
  }

  /// Sets the loading state and notifies the UI.
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Sets an error message and notifies the UI.
  void _setErrorMessage(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      notifyListeners();
    }
  }

  /// Clears any existing error message.
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Performs a user sign-in.
  /// Returns null on success, or an error message string on failure.
  Future<String?> performSignIn(String email, String password) async {
    _clearError();
    try {
      final userEntity = await _signInUserUseCase(SignInParams(email: email, password: password));
      if (userEntity != null) {
        return null; 
      }
      return "An unknown error occurred.";
    } on AuthFailure catch (e) {
      _setErrorMessage(e.message);
      return e.message;
    } catch (e) {
      final unexpectedError = "An unexpected error occurred.";
      _setErrorMessage(unexpectedError);
      return unexpectedError;
    }
  }

  /// Performs a user registration.
  Future<bool> performRegistration({required String email, required String password, required String name}) async {
    _clearError();
    try {
      final userEntity = await _registerUserUseCase(RegisterParams(email: email, password: password, name: name));
      return userEntity != null;
    } on AuthFailure catch (e) {
      _setErrorMessage(e.message);
      return false;
    } catch (e) {
      _setErrorMessage("An unexpected error has occurred.");
      return false;
    }
  }

  /// Sends a password reset email.
  Future<bool> performSendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _sendPasswordResetEmailUseCase(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage("Could not send email: ${e.toString()}");
      _setLoading(false);
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> performSignOut() async {
    _setLoading(true);
    _clearError();
    try {
      await _signOutUserUseCase();
      _updateCurrentUser(null);
    } catch (e) {
      _setErrorMessage("Error during sign out: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  /// Called when the provider is removed from the widget tree.
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}