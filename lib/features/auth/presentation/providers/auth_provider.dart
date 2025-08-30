import 'dart:async';

import 'package:flutter/cupertino.dart';

// Domain-Layer Imports
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
  // Use cases from the domain layer, containing the business logic.
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUserUseCase _signInUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final SignOutUserUseCase _signOutUserUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;

  // Internal state of the provider
  UserEntity? _currentUser;
  bool _isLoading = true; // Starts with true to check the initial state.
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
    // As soon as the provider is created, it starts listening to auth changes.
    _listenToAuthStateChanges();
  }

  // --- Public Getters ---
  // These are used by the UI or ProxyProviders to read the current state.

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


  // --- Private methods for state management ---

  /// Starts the stream that listens for changes in the authentication state.
  void _listenToAuthStateChanges() {
    _authStateSubscription?.cancel(); // Cancel any old subscription as a safety measure.
    _authStateSubscription = _getAuthStateChangesUseCase().listen((userEntity) {
      _setLoading(false); // The first value from the stream ends the initial loading state.
      _updateCurrentUser(userEntity);
    });
  }

  /// Updates the internal user state and notifies all listeners.
  void _updateCurrentUser(UserEntity? user) {
    if (_currentUser != user) {
      _currentUser = user;
      // This is the crucial call! Every time the user changes,
      // all dependent ProxyProviders and widgets in the UI are notified.
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


  // --- Public methods for actions ---
  // These methods are called from the UI to trigger actions.
  /// Performs a user sign-in.
  /// Returns null on success, or an error message string on failure.
  Future<String?> performSignIn(String email, String password) async {
    // _setLoading(true); // <-- DIESE ZEILE ENTFERNEN
    _clearError();
    try {
      final userEntity = await _signInUserUseCase(SignInParams(email: email, password: password));
      // _setLoading(false); // <-- DIESE ZEILE ENTFERNEN
      if (userEntity != null) {
        return null; // Erfolg
      }
      return "An unknown error occurred."; // Sollte nicht erreicht werden
    } on AuthFailure catch (e) {
      _setErrorMessage(e.message);
      // _setLoading(false); // <-- DIESE ZEILE ENTFERNEN
      return e.message;
    } catch (e) {
      final unexpectedError = "An unexpected error occurred.";
      _setErrorMessage(unexpectedError);
      // _setLoading(false); // <-- DIESE ZEILE ENTFERNEN
      return unexpectedError;
    }
  }

  /// Performs a user registration.
  Future<bool> performRegistration({required String email, required String password, required String name}) async {
    // _setLoading(true); // <-- DIESE ZEILE ENTFERNEN
    _clearError();
    try {
      final userEntity = await _registerUserUseCase(RegisterParams(email: email, password: password, name: name));
      // _setLoading(false); // <-- DIESE ZEILE ENTFERNEN
      return userEntity != null;
    } on AuthFailure catch (e) {
      _setErrorMessage(e.message);
      // _setLoading(false); // <-- DIESE ZEILE ENTFERNEN
      return false;
    } catch (e) {
      _setErrorMessage("Ein unerwarteter Fehler ist aufgetreten.");
      // _setLoading(false); // <-- DIESE ZEILE ENTFERNEN
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