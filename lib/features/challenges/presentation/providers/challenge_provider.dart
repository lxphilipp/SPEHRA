// lib/features/challenges/presentation/providers/challenge_provider.dart


import 'package:flutter/material.dart';

// Core & Dependencies
import '/core/utils/app_logger.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';

// Domain & Entities
import '../../domain/entities/challenge_entity.dart';
import '../../domain/usecases/get_all_challenges_stream_usecase.dart';
import '../../domain/usecases/get_challenge_by_id_usecase.dart';
import '../../domain/usecases/create_challenge_usecase.dart';
import '../../domain/usecases/accept_challenge_usecase.dart';
import '../../domain/usecases/complete_challenge_usecase.dart';
import '../../domain/usecases/remove_challenge_from_ongoing_usecase.dart';

/// Manages state related to challenges.
///
/// This provider handles:
/// - Providing a stream of all available challenges.
/// - Fetching details for a single selected challenge.
/// - Managing state for creating and interacting with challenges (accept, complete, etc.).
/// It is designed to be updated by a `ChangeNotifierProxyProvider2` that watches
/// `AuthenticationProvider` and `UserProfileProvider`.
class ChallengeProvider with ChangeNotifier {
  // --- UseCases ---
  final GetAllChallengesStreamUseCase _getAllChallengesStreamUseCase;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  final CreateChallengeUseCase _createChallengeUseCase;
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final CompleteChallengeUseCase _completeChallengeUseCase;
  final RemoveChallengeFromOngoingUseCase _removeChallengeFromOngoingUseCase;

  // --- Internal Provider References ---
  // These will be kept up-to-date by the `updateDependencies` method.
  late AuthenticationProvider _authProvider;
  late UserProfileProvider _userProfileProvider;

  // --- State ---
  Stream<List<ChallengeEntity>> _allChallengesStream = Stream.empty();
  ChallengeEntity? _selectedChallenge;
  bool _isLoadingSelectedChallenge = false;
  String? _selectedChallengeError;

  bool _isCreatingChallenge = false;
  String? _createChallengeError;

  bool _isUpdatingUserChallengeStatus = false;
  String? _userChallengeStatusError;

  /// The constructor is now simple and only requires its own UseCases.
  ChallengeProvider({
    required GetAllChallengesStreamUseCase getAllChallengesStreamUseCase,
    required GetChallengeByIdUseCase getChallengeByIdUseCase,
    required CreateChallengeUseCase createChallengeUseCase,
    required AcceptChallengeUseCase acceptChallengeUseCase,
    required CompleteChallengeUseCase completeChallengeUseCase,
    required RemoveChallengeFromOngoingUseCase removeChallengeFromOngoingUseCase,
  })  : _getAllChallengesStreamUseCase = getAllChallengesStreamUseCase,
        _getChallengeByIdUseCase = getChallengeByIdUseCase,
        _createChallengeUseCase = createChallengeUseCase,
        _acceptChallengeUseCase = acceptChallengeUseCase,
        _completeChallengeUseCase = completeChallengeUseCase,
        _removeChallengeFromOngoingUseCase = removeChallengeFromOngoingUseCase {
    _initializeStreams();
  }

  /// Initialize streams that don't depend on user login state.
  void _initializeStreams() {
    AppLogger.info("ChallengeProvider: Initializing all-challenges stream once.");
    // The stream is created once and converted to a broadcast stream
    // to allow multiple listeners throughout the app's lifecycle.
    _allChallengesStream = _getAllChallengesStreamUseCase()
        .map((challenges) => challenges ?? [])
        .asBroadcastStream();
  }

  // --- Getters for the UI ---
  Stream<List<ChallengeEntity>> get allChallengesStream => _allChallengesStream;

  ChallengeEntity? get selectedChallenge => _selectedChallenge;
  bool get isLoadingSelectedChallenge => _isLoadingSelectedChallenge;
  String? get selectedChallengeError => _selectedChallengeError;

  bool get isCreatingChallenge => _isCreatingChallenge;
  String? get createChallengeError => _createChallengeError;

  bool get isUpdatingUserChallengeStatus => _isUpdatingUserChallengeStatus;
  String? get userChallengeStatusError => _userChallengeStatusError;

  // --- Dependency Update Method ---

  /// The gateway for receiving updates from other providers.
  /// Called by `ChangeNotifierProxyProvider2`.
  void updateDependencies(AuthenticationProvider auth, UserProfileProvider profile) {
    _authProvider = auth;
    _userProfileProvider = profile;
  }

  // --- Public Methods for UI Interaction ---

  Future<void> fetchChallengeDetails(String challengeId) async {
    _isLoadingSelectedChallenge = true;
    _selectedChallengeError = null;
    _selectedChallenge = null;
    notifyListeners();

    final challenge = await _getChallengeByIdUseCase(challengeId);
    if (challenge != null) {
      _selectedChallenge = challenge;
    } else {
      _selectedChallengeError = "Challenge not found or failed to load.";
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
      notifyListeners();
      return true;
    } else {
      _createChallengeError = "Could not create challenge.";
      notifyListeners();
      return false;
    }
  }

  // --- Methods for User Interactions ---
  Future<bool> acceptChallenge(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "User not logged in.";
      notifyListeners();
      return false;
    }

    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _acceptChallengeUseCase(UserTaskParams(userId: userId, challengeId: challengeId));

    _isUpdatingUserChallengeStatus = false;
    if (!success) {
      _userChallengeStatusError = "Could not accept challenge.";
    }

    notifyListeners();
    return success;
  }

  Future<bool> completeChallenge(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "User not logged in.";
      notifyListeners();
      return false;
    }

    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _completeChallengeUseCase(CompleteChallengeParams(
      userId: userId,
      challengeId: challengeId,
    ));

    _isUpdatingUserChallengeStatus = false;
    if (!success) {
      _userChallengeStatusError = "Could not mark challenge as completed.";
    }

    notifyListeners();
    return success;
  }

  Future<bool> removeChallengeFromOngoing(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "User not logged in.";
      notifyListeners();
      return false;
    }

    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _removeChallengeFromOngoingUseCase(UserTaskParams(userId: userId, challengeId: challengeId));

    _isUpdatingUserChallengeStatus = false;
    if (!success) {
      _userChallengeStatusError = "Could not remove challenge from 'Ongoing'.";
    }

    // The reactive UserProfileProvider will handle its own state update.
    notifyListeners();
    return success;
  }
}