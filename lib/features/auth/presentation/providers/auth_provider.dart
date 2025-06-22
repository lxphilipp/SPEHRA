import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
// Importiere die Auth Use Cases
import '../../domain/usecases/get_auth_state_changes_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_user_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/sign_out_user_usecase.dart';
import '../../domain/usecases/send_password_reset_email_usecase.dart';

class AuthenticationProvider with ChangeNotifier {
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUserUseCase _signInUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final SignOutUserUseCase _signOutUserUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;

  UserEntity? _currentUser;
  bool _isLoading = false;
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
    _checkInitialAuthStatus();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get currentUserId => _currentUser?.id;
  String? get currentUserEmail => _currentUser?.email;
  // KEINE Getter mehr für points, level etc. hier, da UserEntity schlank ist
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Wichtig: Expose den Stream für andere Provider (z.B. UserProfileProvider)
  Stream<UserEntity?> get authStateChanges => _getAuthStateChangesUseCase();


  void _listenToAuthStateChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _getAuthStateChangesUseCase().listen((userEntity) {
      _updateCurrentUser(userEntity);
      _clearError();
    });
  }

  Future<void> _checkInitialAuthStatus() async {
    _setLoading(true);
    _currentUser = await _getCurrentUserUseCase();
    _setLoading(false);
  }

  Future<bool> performSignIn(String email, String password) async {
    _setLoading(true); _clearError();
    final userEntity = await _signInUserUseCase(SignInParams(email: email, password: password));
    _setLoading(false);
    if (userEntity != null) { _updateCurrentUser(userEntity); return true; }
    _setErrorMessage("Login fehlgeschlagen."); notifyListeners(); return false;
  }

  Future<bool> performRegistration({required String email, required String password, required String name}) async {
    _setLoading(true); _clearError();
    final userEntity = await _registerUserUseCase(RegisterParams(email: email, password: password, name: name));
    _setLoading(false);
    if (userEntity != null) { _updateCurrentUser(userEntity); return true; }
    _setErrorMessage("Registrierung fehlgeschlagen."); notifyListeners(); return false;
  }

  Future<bool> performSendPasswordResetEmail(String email) async {
    _setLoading(true); _clearError();
    final success = await _sendPasswordResetEmailUseCase(email);
    _setLoading(false);
    if (!success) { _setErrorMessage("Passwort-Reset E-Mail konnte nicht gesendet werden."); notifyListeners(); }
    return success;
  }

  Future<void> performSignOut() async {
    _setLoading(true); _clearError();
    try {
      await _signOutUserUseCase();
      // Der authStateChanges Stream wird _currentUser auf null setzen
    } catch (e) { _setErrorMessage("Fehler beim Ausloggen."); }
    _setLoading(false); // notifyListeners() wird durch setLoading gerufen oder wenn _currentUser sich ändert
  }

  void _updateCurrentUser(UserEntity? user) {
    if (_currentUser != user) {
      _currentUser = user;
      notifyListeners();
    }
  }
  void _setLoading(bool loading) { /* ... */ if(_isLoading != loading) {_isLoading = loading; notifyListeners();} }
  void _setErrorMessage(String? message) { /* ... */ _errorMessage = message; /* notifyListeners(); */ }
  void _clearError() { /* ... */ if(_errorMessage != null) _errorMessage = null; /* notifyListeners(); */ }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}