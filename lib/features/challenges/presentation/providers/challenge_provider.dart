import 'dart:async';
import 'package:flutter/cupertino.dart';

import '/core/utils/app_logger.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:collection/collection.dart';

import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/challenge_filter_state.dart';
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
/// - Managing the filter and sort state for the challenge list.
/// - Managing state for creating and interacting with challenges (accept, complete, etc.).
class ChallengeProvider with ChangeNotifier {
  // --- UseCases ---
  final GetAllChallengesStreamUseCase _getAllChallengesStreamUseCase;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  final CreateChallengeUseCase _createChallengeUseCase;
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final CompleteChallengeUseCase _completeChallengeUseCase;
  final RemoveChallengeFromOngoingUseCase _removeChallengeFromOngoingUseCase;

  // --- Internal Provider References ---
  late AuthenticationProvider _authProvider;
  late UserProfileProvider _userProfileProvider;

  // --- State ---
  List<ChallengeEntity> _allChallenges = [];
  StreamSubscription? _allChallengesSubscription;

  // Filter- und Sortier-Zustand
  ChallengeFilterState _filterState = const ChallengeFilterState();
  String _sortCriteria = 'createdAt';
  bool _isSortAscending = false;

  ChallengeEntity? _selectedChallenge;
  bool _isLoadingSelectedChallenge = false;
  String? _selectedChallengeError;

  bool _isCreatingChallenge = false;
  String? _createChallengeError;

  bool _isUpdatingUserChallengeStatus = false;
  String? _userChallengeStatusError;

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

  // --- Getters für die UI ---
  ChallengeFilterState get filterState => _filterState;

  ChallengeEntity? get selectedChallenge => _selectedChallenge;
  bool get isLoadingSelectedChallenge => _isLoadingSelectedChallenge;
  String? get selectedChallengeError => _selectedChallengeError;

  bool get isCreatingChallenge => _isCreatingChallenge;
  String? get createChallengeError => _createChallengeError;

  bool get isUpdatingUserChallengeStatus => _isUpdatingUserChallengeStatus;
  String? get userChallengeStatusError => _userChallengeStatusError;

  String get sortCriteria => _sortCriteria;
  bool get isSortAscending => _isSortAscending;

  /// Wendet die aktuellen Filter- und Sortiereinstellungen auf die Challenge-Liste an.
  /// Die UI sollte immer diesen Getter verwenden, um die anzuzeigenden Daten zu erhalten.
  List<ChallengeEntity> get filteredChallenges {
    List<ChallengeEntity> filtered = List.from(_allChallenges);

    // 1. Filtern nach Textsuche
    if (_filterState.searchText.isNotEmpty) {
      filtered = filtered.where((c) => c.title.toLowerCase().contains(_filterState.searchText.toLowerCase())).toList();
    }

    // 2. Filtern nach Schwierigkeit
    if (_filterState.selectedDifficulties.isNotEmpty) {
      filtered = filtered.where((c) => _filterState.selectedDifficulties.contains(c.difficulty)).toList();
    }

    // 3. Filtern nach Datum
    if (_filterState.dateRange != null) {
      filtered = filtered.where((c) {
        if (c.createdAt == null) return false;
        final isAfterStart = c.createdAt!.isAfter(_filterState.dateRange!.start.subtract(const Duration(days: 1)));
        final isBeforeEnd = c.createdAt!.isBefore(_filterState.dateRange!.end.add(const Duration(days: 1)));
        return isAfterStart && isBeforeEnd;
      }).toList();
    }

     if (_filterState.selectedSdgKeys.isNotEmpty) {
       filtered = filtered.where((c) =>
           c.categories.any((catKey) => _filterState.selectedSdgKeys.contains(catKey))
       ).toList();
     }

    // 5. Sortieren
    filtered.sort((a, b) {
      int comparison;
      switch (_sortCriteria) {
        case 'points':
          comparison = a.points.compareTo(b.points);
          break;
        case 'difficulty':
          const order = {'Easy': 1, 'Normal': 2, 'Advanced': 3, 'Experienced': 4};
          comparison = (order[a.difficulty] ?? 5).compareTo(order[b.difficulty] ?? 5);
          break;
        case 'createdAt':
        default:
          comparison = (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0));
          break;
      }
      return _isSortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void setSortCriteria(String newCriteria) {
    // Wenn das gleiche Kriterium erneut gewählt wird, kehre die Richtung um.
    if (_sortCriteria == newCriteria) {
      _isSortAscending = !_isSortAscending;
    } else {
      _sortCriteria = newCriteria;
      // Setze auf eine sinnvolle Standardrichtung für das neue Kriterium
      _isSortAscending = (newCriteria == 'difficulty'); // z.B. Schwierigkeit aufsteigend, Rest absteigend
    }
    notifyListeners();
  }

  void toggleSortDirection() {
    _isSortAscending = !_isSortAscending;
    notifyListeners();
  }

  // --- Methoden zur Zustandsänderung ---

  /// Aktualisiert den Filterzustand und benachrichtigt die UI.
  void updateFilter(ChallengeFilterState newFilter) {
    _filterState = newFilter;
    notifyListeners();
  }

  void _initializeStreams() {
    AppLogger.info("ChallengeProvider: Initializing all-challenges stream.");
    _allChallengesSubscription?.cancel();
    _allChallengesSubscription = _getAllChallengesStreamUseCase()
        .map((challenges) => challenges ?? [])
        .listen((challenges) {
      if (!const ListEquality().equals(_allChallenges, challenges)) {
        _allChallenges = challenges;
        notifyListeners();
      }
    });
  }

  void updateDependencies(AuthenticationProvider auth, UserProfileProvider profile) {
    _authProvider = auth;
    _userProfileProvider = profile;
  }

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

    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    _allChallengesSubscription?.cancel();
    super.dispose();
  }
}