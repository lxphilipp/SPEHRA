import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '/core/utils/app_logger.dart';
import '/features/auth/domain/entities/user_entity.dart'; // Für den Parameter von _onAuthChanged
import '/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/watch_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_data_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../../domain/usecases/get_profile_stats_pie_chart_usecase.dart';


class UserProfileProvider with ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final WatchUserProfileUseCase _watchUserProfileUseCase;
  final UpdateProfileDataUseCase _updateProfileDataUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final GetProfileStatsPieChartUseCase _getProfileStatsPieChartUseCase;
  final AuthenticationProvider _authProvider;

  UserProfileEntity? _userProfile;
  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  String? _profileError;

  Stream<List<PieChartSectionData>?> _pieChartDataStream = Stream.value(null);

  // Instanzvariablen für die Subscriptions
  StreamSubscription<UserEntity?>? _authStateSubscription; // Typ angepasst
  StreamSubscription<UserProfileEntity?>? _userProfileSubscription; // Typ angepasst

  UserProfileProvider({
    required GetUserProfileUseCase getUserProfileUseCase,
    required WatchUserProfileUseCase watchUserProfileUseCase,
    required UpdateProfileDataUseCase updateProfileDataUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required GetProfileStatsPieChartUseCase getProfileStatsPieChartUseCase,
    required AuthenticationProvider authProvider,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _watchUserProfileUseCase = watchUserProfileUseCase,
        _updateProfileDataUseCase = updateProfileDataUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase,
        _getProfileStatsPieChartUseCase = getProfileStatsPieChartUseCase,
        _authProvider = authProvider {
    // Korrekter Listener für Auth-Änderungen
    // Annahme: MYAuthProvider hat einen Stream `authStateChanges` vom Typ Stream<UserEntity?>
    _authStateSubscription = _authProvider.authStateChanges.listen(_onAuthChanged);
    _initProfileAndStatsIfNeeded(); // Initiales Laden/Prüfen
  }

  UserProfileEntity? get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get profileError => _profileError;
  Stream<List<PieChartSectionData>?> get pieChartDataStream => _pieChartDataStream;

  // _onAuthChanged akzeptiert jetzt den User vom Stream des AuthProviders
  void _onAuthChanged(UserEntity? authUserFromStream) { // Parameter ist der User vom Auth-Stream
    AppLogger.debug("UserProfileProvider: Auth state changed via listener. User from stream: ${authUserFromStream?.email}");
    // _initProfileAndStatsIfNeeded wird den aktuellen _authProvider.currentUserId verwenden,
    // der durch den eigenen Listener des MYAuthProviders auf _authRepository.authStateChanges aktualisiert wurde.
    _initProfileAndStatsIfNeeded();
  }

  void _initProfileAndStatsIfNeeded() {
    final userId = _authProvider.currentUserId; // Hole die aktuelle UserID vom AuthProvider

    if (_authProvider.isLoggedIn && userId != null) {
      // Nur neu initialisieren, wenn sich die UserID geändert hat oder noch kein Abo besteht
      if (_userProfile?.id != userId || _userProfileSubscription == null) {
        AppLogger.debug("UserProfileProvider: Initializing profile and stats for user $userId");
        _setLoadingProfile(true);
        _clearProfileError();

        _userProfileSubscription?.cancel();
        _userProfileSubscription = _watchUserProfileUseCase(userId).listen(
              (profileEntity) { // profileEntity ist UserProfileEntity?
            _userProfile = profileEntity;
            if (profileEntity == null && _isLoadingProfile) {
              _setProfileError("Profil konnte nicht geladen werden (Stream lieferte null).");
            } else if (profileEntity != null) {
              _clearProfileError();
            }
            if (_isLoadingProfile) _setLoadingProfile(false);
            // notifyListeners() wird durch _setLoadingProfile oder _setProfileError gerufen
          },
          onError: (error) {
            AppLogger.error("UserProfileProvider: Error in profile stream for $userId", error);
            _setProfileError("Fehler beim Laden des Profils: ${error.toString()}");
            _userProfile = null;
            _setLoadingProfile(false);
          },
        );

        _pieChartDataStream = _getProfileStatsPieChartUseCase(userId);
        notifyListeners(); // Um den neuen pieChartDataStream bekannt zu machen
      }
    } else {
      // User ist ausgeloggt oder userId ist null
      AppLogger.debug("UserProfileProvider: User logged out or no UserID, resetting profile state");
      _userProfile = null;
      _userProfileSubscription?.cancel();
      _userProfileSubscription = null; // Explizit auf null setzen
      _pieChartDataStream = Stream.value(null);
      _clearProfileError();
      _setLoadingProfile(false); // Sicherstellen, dass kein Ladezustand hängen bleibt
      // notifyListeners() wird durch _setLoadingProfile gerufen
    }
  }

  Future<void> fetchUserProfileManually() async { // Umbenannt für Klarheit
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _setProfileError("Kein Benutzer eingeloggt, um Profil zu laden.");
      notifyListeners();
      return;
    }
    _setLoadingProfile(true);
    _clearProfileError();
    final profile = await _getUserProfileUseCase(userId);
    _userProfile = profile; // Setze Profil, auch wenn es null ist (Fehlerfall)
    if (profile == null) {
      _setProfileError("Profil konnte nicht manuell geladen werden.");
    }
    _setLoadingProfile(false); // Ruft notifyListeners
  }

  Future<bool> updateProfile({
    required String name,
    required int age,
    required String studyField,
    required String school,
    File? imageFileToUpload,
  }) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _setProfileError("Nicht eingeloggt für Profilupdate");
      notifyListeners();
      return false;
    }

    _isUpdatingProfile = true;
    _clearProfileError();
    notifyListeners();

    String? finalImageUrl = _userProfile?.profileImageUrl;
    bool success = true; // Annahme, dass es erstmal klappt

    if (imageFileToUpload != null) {
      final uploadedUrl = await _uploadProfileImageUseCase(UploadProfileImageParams(
        userId: userId,
        imageFile: imageFileToUpload,
        oldImageUrl: _userProfile?.profileImageUrl,
      ));

      if (uploadedUrl == null) {
        _setProfileError("Bild-Upload fehlgeschlagen.");
        success = false;
      } else {
        finalImageUrl = uploadedUrl;
      }
    }

    if (success) { // Nur Textdaten updaten, wenn Bild-Upload erfolgreich war oder kein neues Bild da ist
      success = await _updateProfileDataUseCase(UpdateProfileDataParams(
        userId: userId, name: name, age: age, studyField: studyField, school: school,
      ));

      if (success) {
        // Optimistisches Update oder Verlassen auf den Stream
        // Für sofortiges Feedback ist lokales Update besser:
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(
            name: name, age: age, studyField: studyField, school: school,
            profileImageUrl: finalImageUrl,
          );
        }
        _clearProfileError();
      } else {
        _setProfileError("Profil-Update der Textdaten fehlgeschlagen.");
      }
    }

    _isUpdatingProfile = false;
    notifyListeners();
    return success;
  }

  void _setLoadingProfile(bool value) {
    if (_isLoadingProfile == value) return;
    _isLoadingProfile = value;
    notifyListeners();
  }

  void _setProfileError(String? message) {
    _profileError = message;
    // notifyListeners(); // Wird oft zusammen mit setLoading(false) oder explizit danach gerufen
  }

  void _clearProfileError() {
    if (_profileError != null) {
      _profileError = null;
      // notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}