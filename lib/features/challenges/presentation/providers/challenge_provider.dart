import 'dart:async';
import 'package:flutter/material.dart';
import '/core/utils/app_logger.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/usecases/get_all_challenges_stream_usecase.dart';
import '../../domain/usecases/get_challenge_by_id_usecase.dart';
import '../../domain/usecases/create_challenge_usecase.dart';
// Importiere die Use Cases für Challenge-Interaktionen (Accept, Complete, Remove)
import '../../domain/usecases/accept_challenge_usecase.dart'; // Annahme: Diese existieren jetzt
import '../../domain/usecases/complete_challenge_usecase.dart';
import '../../domain/usecases/remove_challenge_from_ongoing_usecase.dart';


class ChallengeProvider with ChangeNotifier {
  final GetAllChallengesStreamUseCase _getAllChallengesStreamUseCase;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  final CreateChallengeUseCase _createChallengeUseCase;
  // Use Cases für User-Interaktionen mit Challenges
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final CompleteChallengeUseCase _completeChallengeUseCase;
  final RemoveChallengeFromOngoingUseCase _removeChallengeFromOngoingUseCase;

  final AuthenticationProvider _authProvider;
  final UserProfileProvider _userProfileProvider; // Für Task-Updates und Punkte/Level

  ChallengeProvider({
    required GetAllChallengesStreamUseCase getAllChallengesStreamUseCase,
    required GetChallengeByIdUseCase getChallengeByIdUseCase,
    required CreateChallengeUseCase createChallengeUseCase,
    required AcceptChallengeUseCase acceptChallengeUseCase,
    required CompleteChallengeUseCase completeChallengeUseCase,
    required RemoveChallengeFromOngoingUseCase removeChallengeFromOngoingUseCase,
    required AuthenticationProvider authProvider,
    required UserProfileProvider userProfileProvider,
  })  : _getAllChallengesStreamUseCase = getAllChallengesStreamUseCase,
        _getChallengeByIdUseCase = getChallengeByIdUseCase,
        _createChallengeUseCase = createChallengeUseCase,
        _acceptChallengeUseCase = acceptChallengeUseCase,
        _completeChallengeUseCase = completeChallengeUseCase,
        _removeChallengeFromOngoingUseCase = removeChallengeFromOngoingUseCase,
        _authProvider = authProvider,
        _userProfileProvider = userProfileProvider;

  // --- State für Challenge-Liste ---
  Stream<List<ChallengeEntity>?> get allChallengesStream {
    AppLogger.info("ChallengeProvider: Creating challenges stream");
    return _getAllChallengesStreamUseCase().map((challenges) {
      AppLogger.info("ChallengeProvider: Stream received ${challenges?.length ?? 0} challenges");
      if (challenges != null && challenges.isNotEmpty) {
        AppLogger.debug("ChallengeProvider: Challenge IDs: ${challenges.map((c) => c.id).join(', ')}");
      }
      return challenges;
    });
  }

  // --- State für ausgewählte Challenge-Details ---
  ChallengeEntity? _selectedChallenge;
  ChallengeEntity? get selectedChallenge => _selectedChallenge;
  bool _isLoadingSelectedChallenge = false;
  bool get isLoadingSelectedChallenge => _isLoadingSelectedChallenge;
  String? _selectedChallengeError;
  String? get selectedChallengeError => _selectedChallengeError;

  // --- State für das Erstellen einer Challenge ---
  bool _isCreatingChallenge = false;
  bool get isCreatingChallenge => _isCreatingChallenge;
  String? _createChallengeError;
  String? get createChallengeError => _createChallengeError;

  // --- State für User-Interaktionen ---
  bool _isUpdatingUserChallengeStatus = false;
  bool get isUpdatingUserChallengeStatus => _isUpdatingUserChallengeStatus;
  String? _userChallengeStatusError;
  String? get userChallengeStatusError => _userChallengeStatusError;


  Future<void> fetchChallengeDetails(String challengeId) async {
    _isLoadingSelectedChallenge = true;
    _selectedChallengeError = null;
    _selectedChallenge = null;
    notifyListeners();

    final challenge = await _getChallengeByIdUseCase(challengeId);
    if (challenge != null) {
      _selectedChallenge = challenge;
    } else {
      _selectedChallengeError = "Challenge nicht gefunden oder Fehler beim Laden.";
    }
    _isLoadingSelectedChallenge = false;
    notifyListeners();
  }

  Future<bool> createChallenge({
    required String title, required String description, required String task,
    required int points, required List<String> categories, required String difficulty,
  }) async {
    _isCreatingChallenge = true;
    _createChallengeError = null;
    notifyListeners();

    final newChallengeId = await _createChallengeUseCase(CreateChallengeParams(
      title: title, description: description, task: task, points: points,
      categories: categories, difficulty: difficulty,
    ));

    _isCreatingChallenge = false;
    if (newChallengeId != null) {
      notifyListeners(); // UI informieren, dass sich die Challenge-Liste ändern könnte
      return true;
    } else {
      _createChallengeError = "Challenge konnte nicht erstellt werden.";
      notifyListeners();
      return false;
    }
  }

  // --- Methoden für User-Interaktionen ---
  Future<bool> acceptChallenge(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "Benutzer nicht eingeloggt.";
      notifyListeners();
      return false;
    }
    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _acceptChallengeUseCase(UserTaskParams(userId: userId, challengeId: challengeId));

    _isUpdatingUserChallengeStatus = false;
    if (success) {
      // Triggere ein Neuladen des User-Profils, damit die Task-Listen aktuell sind
      await _userProfileProvider.fetchUserProfileManually();
    } else {
      _userChallengeStatusError = "Challenge konnte nicht angenommen werden.";
    }
    notifyListeners();
    return success;
  }

  Future<bool> completeChallenge(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) { // Kein User eingeloggt
      _userChallengeStatusError = "Benutzer nicht eingeloggt.";
      notifyListeners();
      return false;
    }

    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    // Rufe den Use Case NUR mit userId und challengeId auf
    final success = await _completeChallengeUseCase(CompleteChallengeParams(
      userId: userId,
      challengeId: challengeId,
    ));

    _isUpdatingUserChallengeStatus = false;
    if (success) {
      await _userProfileProvider.fetchUserProfileManually();
    } else {
      _userChallengeStatusError = "Challenge konnte nicht als erledigt markiert werden.";
    }
    notifyListeners();
    return success;
  }

  Future<bool> removeChallengeFromOngoing(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "Benutzer nicht eingeloggt.";
      notifyListeners();
      return false;
    }
    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _removeChallengeFromOngoingUseCase(UserTaskParams(userId: userId, challengeId: challengeId));

    _isUpdatingUserChallengeStatus = false;
    if (success) {
      await _userProfileProvider.fetchUserProfileManually();
    } else {
      _userChallengeStatusError = "Challenge konnte nicht von 'Laufend' entfernt werden.";
    }
    notifyListeners();
    return success;
  }
}