import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart'; // Für den Listenvergleich

// Core & Usecases
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/create_challenge_usecase.dart';
import '../../domain/usecases/get_all_challenges_stream_usecase.dart';
import '../../domain/usecases/get_challenge_by_id_usecase.dart';
import '../../domain/usecases/accept_challenge_usecase.dart';
import '../../domain/usecases/complete_challenge_usecase.dart';
import '../../domain/usecases/get_llm_feedback_usecase.dart';
import '../../domain/usecases/remove_challenge_from_ongoing_usecase.dart';

// Domain Entities
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/challenge_filter_state.dart';
import '../../domain/entities/trackable_task.dart';

// Dependency Providers
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../domain/usecases/search_location_usecase.dart';


/// Verwaltet den gesamten Zustand, der mit Challenges zu tun hat.
///
/// Diese Klasse ist verantwortlich für:
/// - Das Bereitstellen und Filtern der Liste aller verfügbaren Challenges.
/// - Das Holen der Details für eine einzelne, ausgewählte Challenge.
/// - Die Verwaltung des Zustands für den mehrschrittigen "Challenge-Baukasten".
/// - Die Interaktion mit dem Benutzerprofil (Akzeptieren, Abschließen von Challenges).
class ChallengeProvider with ChangeNotifier {
  // --- UseCases aus der Domain-Schicht ---
  final GetAllChallengesStreamUseCase _getAllChallengesStreamUseCase;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  final CreateChallengeUseCase _createChallengeUseCase;
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final CompleteChallengeUseCase _completeChallengeUseCase;
  final RemoveChallengeFromOngoingUseCase _removeChallengeFromOngoingUseCase;
  final SearchLocationUseCase _searchLocationUseCase;
  final GetLlmFeedbackUseCase _getLlmFeedbackUseCase;

  // --- Interne Referenzen auf andere Provider ---
  late AuthenticationProvider _authProvider;
  late UserProfileProvider _userProfileProvider;

  // --- State für die Challenge-Liste und Filterung ---
  List<ChallengeEntity> _allChallenges = [];
  StreamSubscription? _allChallengesSubscription;
  ChallengeFilterState _filterState = const ChallengeFilterState();
  String _sortCriteria = 'createdAt';
  bool _isSortAscending = false;

  // --- State für die Detailansicht ---
  ChallengeEntity? _selectedChallenge;
  bool _isLoadingSelectedChallenge = false;
  String? _selectedChallengeError;

  // --- State für den Challenge-Baukasten ---
  ChallengeEntity? _challengeInProgress;
  bool _isCreatingChallenge = false;
  String? _createChallengeError;

  // --- State für User-Interaktionen ---
  bool _isUpdatingUserChallengeStatus = false;
  String? _userChallengeStatusError;

  // --- Page Controller ---
  PageController? _pageController;
  PageController? get pageController => _pageController;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  // --- State for Location Search ---

  List<AddressEntity> _locationSearchResults = [];
  List<AddressEntity> get locationSearchResults => _locationSearchResults;
  bool _isSearchingLocation = false;
  bool get isSearchingLocation => _isSearchingLocation;

  // --- State for LLM Feedback ---

  Timer? _debounce;
  bool _isFetchingFeedback = false;
  String? _feedbackError;
  Map<String, dynamic> _llmFeedbackData = {};

  ChallengeProvider({
    required GetAllChallengesStreamUseCase getAllChallengesStreamUseCase,
    required GetChallengeByIdUseCase getChallengeByIdUseCase,
    required CreateChallengeUseCase createChallengeUseCase,
    required AcceptChallengeUseCase acceptChallengeUseCase,
    required CompleteChallengeUseCase completeChallengeUseCase,
    required RemoveChallengeFromOngoingUseCase removeChallengeFromOngoingUseCase,
    required SearchLocationUseCase searchLocationUseCase,
    required GetLlmFeedbackUseCase getLlmFeedbackUseCase,
  })  : _getAllChallengesStreamUseCase = getAllChallengesStreamUseCase,
        _getChallengeByIdUseCase = getChallengeByIdUseCase,
        _createChallengeUseCase = createChallengeUseCase,
        _acceptChallengeUseCase = acceptChallengeUseCase,
        _completeChallengeUseCase = completeChallengeUseCase,
        _removeChallengeFromOngoingUseCase = removeChallengeFromOngoingUseCase,
        _searchLocationUseCase = searchLocationUseCase,
        _getLlmFeedbackUseCase = getLlmFeedbackUseCase{
    _initializeStreams();
  }

  // --- Getters für die UI ---

  // Listen- und Filter-Zustand
  ChallengeFilterState get filterState => _filterState;
  String get sortCriteria => _sortCriteria;
  bool get isSortAscending => _isSortAscending;

  // Detailansicht-Zustand
  ChallengeEntity? get selectedChallenge => _selectedChallenge;
  bool get isLoadingSelectedChallenge => _isLoadingSelectedChallenge;
  String? get selectedChallengeError => _selectedChallengeError;

  // Baukasten-Zustand
  ChallengeEntity? get challengeInProgress => _challengeInProgress;
  bool get isCreatingChallenge => _isCreatingChallenge;
  String? get createChallengeError => _createChallengeError;

  // Interaktions-Zustand
  bool get isUpdatingUserChallengeStatus => _isUpdatingUserChallengeStatus;
  String? get userChallengeStatusError => _userChallengeStatusError;

  // Feedback-Zustand
  bool get isFetchingFeedback => _isFetchingFeedback;
  String? get feedbackError => _feedbackError;
  Map<String, dynamic> get llmFeedbackData => _llmFeedbackData;


  /// Gibt die gefilterte und sortierte Liste der Challenges zurück.
  /// Die UI sollte immer diesen Getter verwenden.
  List<ChallengeEntity> get filteredChallenges {
    List<ChallengeEntity> filtered = List.from(_allChallenges);

    if (_filterState.searchText.isNotEmpty) {
      filtered = filtered.where((c) => c.title.toLowerCase().contains(_filterState.searchText.toLowerCase())).toList();
    }
    if (_filterState.selectedDifficulties.isNotEmpty) {
      filtered = filtered.where((c) => _filterState.selectedDifficulties.contains(c.calculatedDifficulty)).toList();
    }
    if (_filterState.selectedSdgKeys.isNotEmpty) {
      filtered = filtered.where((c) => c.categories.any((catKey) => _filterState.selectedSdgKeys.contains(catKey))).toList();
    }

    filtered.sort((a, b) {
      int comparison;
      switch (_sortCriteria) {
        case 'points':
          comparison = a.calculatedPoints.compareTo(b.calculatedPoints);
          break;
        case 'difficulty':
          const order = {'Easy': 1, 'Normal': 2, 'Advanced': 3, 'Experienced': 4};
          comparison = (order[a.calculatedDifficulty] ?? 5).compareTo(order[b.calculatedDifficulty] ?? 5);
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

  List<ChallengeEntity> get discoverChallenges {
    final profile = _userProfileProvider.userProfile;
    if (profile == null) return [];
    final ongoingIds = profile.ongoingTasks.toSet();
    final completedIds = profile.completedTasks.toSet();

    return filteredChallenges.where((c) {
      return !ongoingIds.contains(c.id) && !completedIds.contains(c.id);
    }).toList();
  }

  List<ChallengeEntity> get ongoingChallenges {
    final profile = _userProfileProvider.userProfile;
    if (profile == null) return [];
    final ongoingIds = profile.ongoingTasks.toSet();

    return filteredChallenges.where((c) => ongoingIds.contains(c.id)).toList();
  }

  List<ChallengeEntity> get completedChallenges {
    final profile = _userProfileProvider.userProfile;
    if (profile == null) return [];
    final completedIds = profile.completedTasks.toSet();

    return filteredChallenges.where((c) => completedIds.contains(c.id)).toList();
  }

  // --- Methoden zur Zustandsänderung ---

  void updateDependencies(AuthenticationProvider auth, UserProfileProvider profile) {
    _authProvider = auth;
    _userProfileProvider = profile;
  }

  void _initializeStreams() {
    AppLogger.info("ChallengeProvider: Initializing all-challenges stream.");
    _allChallengesSubscription?.cancel();
    _allChallengesSubscription = _getAllChallengesStreamUseCase(NoParams())
        .asStream()
        .asyncExpand((stream) => stream)
        .map((challenges) => challenges ?? [])
        .listen((challenges) {
      if (!const ListEquality().equals(_allChallenges, challenges)) {
        _allChallenges = challenges;
        notifyListeners();
      }
    });
    AppLogger.info("All challenges: ${_allChallenges.length}");
  }

  void updateFilter(ChallengeFilterState newFilter) {
    _filterState = newFilter;
    notifyListeners();
  }

  void setSortCriteria(String newCriteria) {
    if (_sortCriteria == newCriteria) {
      _isSortAscending = !_isSortAscending;
    } else {
      _sortCriteria = newCriteria;
      _isSortAscending = (newCriteria == 'difficulty' || newCriteria == 'points');
    }
    notifyListeners();
  }

  Future<void> fetchChallengeDetails(String challengeId) async {
    _isLoadingSelectedChallenge = true;
    _selectedChallengeError = null;
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

  // --- Baukasten-Methoden ---

  void startChallengeCreation(String authorId) {
    _challengeInProgress = ChallengeEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      description: '',
      categories: [],
      authorId: authorId,
      tasks: [],
      llmFeedback: {},
    );

    _pageController = PageController();
    _currentPage = 0;

    _llmFeedbackData = {};
    notifyListeners();
  }
  void requestLlmFeedback(String step) {
    if (_challengeInProgress == null) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _isFetchingFeedback = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 1200), () async {
      try {
        final challengeData = _challengeInProgress!;
        final feedbackJsonString = await _getLlmFeedbackUseCase(
          GetLlmFeedbackParams(step: step, challengeData: challengeData),
        );

        if (feedbackJsonString != null) {
          final feedbackMap = json.decode(feedbackJsonString) as Map<String, dynamic>;
          _llmFeedbackData[step] = feedbackMap;
          _feedbackError = null;
        } else {
          _feedbackError = "Failed to get feedback.";
        }
      } catch (e) {
        AppLogger.error("LLM Feedback Error in Provider", e);
        _feedbackError = e.toString();
        _llmFeedbackData.remove(step);
      } finally {
        _isFetchingFeedback = false;
        notifyListeners();
      }
    });
  }

  void updateChallengeInProgress({
    String? title,
    String? description,
    List<String>? categories,
    Map<String, String>? llmFeedback,
  }) {
    if (_challengeInProgress == null) return;
    _challengeInProgress = ChallengeEntity(
        id: _challengeInProgress!.id,
        title: title ?? _challengeInProgress!.title,
        description: description ?? _challengeInProgress!.description,
        categories: categories ?? _challengeInProgress!.categories,
        authorId: _challengeInProgress!.authorId,
        tasks: _challengeInProgress!.tasks,
        llmFeedback: llmFeedback ?? _challengeInProgress!.llmFeedback
    );
    notifyListeners();
  }

  void addTaskToChallenge(TrackableTask task) {
    if (_challengeInProgress == null) return;
    final updatedTasks = List<TrackableTask>.from(_challengeInProgress!.tasks)..add(task);
    _challengeInProgress = ChallengeEntity(
      id: _challengeInProgress!.id,
      title: _challengeInProgress!.title,
      description: _challengeInProgress!.description,
      categories: _challengeInProgress!.categories,
      authorId: _challengeInProgress!.authorId,
      tasks: updatedTasks,
      llmFeedback: _challengeInProgress!.llmFeedback,
    );
    notifyListeners();
    AppLogger.info("Added task to challenge: ${task.runtimeType.toString()}");
    requestLlmFeedback('tasks');
  }

  void removeTaskFromChallenge(int index) {
    if (_challengeInProgress == null || index < 0 || index >= _challengeInProgress!.tasks.length) return;
    final updatedTasks = List<TrackableTask>.from(_challengeInProgress!.tasks)..removeAt(index);
    _challengeInProgress = ChallengeEntity(
      id: _challengeInProgress!.id,
      title: _challengeInProgress!.title,
      description: _challengeInProgress!.description,
      categories: _challengeInProgress!.categories,
      authorId: _challengeInProgress!.authorId,
      tasks: updatedTasks,
      llmFeedback: _challengeInProgress!.llmFeedback,
    );
    notifyListeners();
    requestLlmFeedback('tasks');
  }

  Future<String?> saveChallenge() async {
    if (_challengeInProgress == null) {
      _createChallengeError = "Keine Challenge zum Speichern vorhanden.";
      notifyListeners();
      return null;
    }

    _isCreatingChallenge = true;
    _createChallengeError = null;
    notifyListeners();

    final params = CreateChallengeParams(
      title: _challengeInProgress!.title,
      description: _challengeInProgress!.description,
      categories: _challengeInProgress!.categories,
      authorId: _challengeInProgress!.authorId,
      tasks: _challengeInProgress!.tasks,
      llmFeedback: _challengeInProgress!.llmFeedback,
    );

    final newId = await _createChallengeUseCase(params);

    _isCreatingChallenge = false;
    if (newId != null) {
      _challengeInProgress = null; // Baukasten nach Erfolg zurücksetzen.
    } else {
      _createChallengeError = "Fehler beim Speichern der Challenge.";
    }
    notifyListeners();
    return newId;
  }

  // --- User-Interaktions-Methoden ---

  /// Navigiert zur nächsten Seite im PageView.
  void nextPage() {
    if (_pageController == null || !_pageController!.hasClients) return;
    _currentPage++;
    _pageController!.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    notifyListeners();
  }

  /// Navigiert zur vorherigen Seite im PageView.
  void previousPage() {
    if (_pageController == null || !_pageController!.hasClients) return;
    _currentPage--;
    _pageController!.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    notifyListeners();
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
    if (!success) _userChallengeStatusError = "Could not accept challenge.";
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

    final success = await _completeChallengeUseCase(CompleteChallengeParams(userId: userId, challengeId: challengeId));

    _isUpdatingUserChallengeStatus = false;
    if (!success) _userChallengeStatusError = "Could not mark challenge as completed.";
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
    if (!success) _userChallengeStatusError = "Could not remove challenge from 'Ongoing'.";
    notifyListeners();
    return success;
  }

  Future<void> searchLocation(String query) async {
    _locationSearchResults = [];
    _isSearchingLocation = true;
    notifyListeners();

    try {
      final results = await _searchLocationUseCase(query);
      _locationSearchResults = results;
    } catch (e) {
      AppLogger.error("Search Location UseCase failed", e);
      _locationSearchResults = [];
    } finally {
      _isSearchingLocation = false;
      notifyListeners();
    }
  }

  void clearLocationSearch() {
    _locationSearchResults = [];
  }

  @override
  void dispose() {
    _allChallengesSubscription?.cancel();
    _pageController?.dispose();
    _debounce?.cancel(); // Wichtig: Timer im dispose aufräumen!
    super.dispose();
  }
}