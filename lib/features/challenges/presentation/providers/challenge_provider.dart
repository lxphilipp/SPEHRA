import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart'; // Für den Listenvergleich

// Core & Usecases
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/challenge_progress_entity.dart';
import '../../domain/usecases/create_challenge_usecase.dart';
import '../../domain/usecases/get_all_challenges_stream_usecase.dart';
import '../../domain/usecases/get_challenge_by_id_usecase.dart';
import '../../domain/usecases/accept_challenge_usecase.dart';
import '../../domain/usecases/complete_challenge_usecase.dart';
import '../../domain/usecases/get_llm_feedback_usecase.dart';
import '../../domain/usecases/refresh_steps_for_task_usecase.dart';
import '../../domain/usecases/remove_challenge_from_ongoing_usecase.dart';

// Domain Entities
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/challenge_filter_state.dart';
import '../../domain/entities/trackable_task.dart';

// Dependency Providers
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../domain/usecases/search_location_usecase.dart';
import '../../domain/usecases/select_image_for_task_usecase.dart';
import '../../domain/usecases/start_challenge_usecase.dart';
import '../../domain/usecases/toggle_checkbox_task_usecase.dart';
import '../../domain/usecases/update_task_progress_usecase.dart';
import '../../domain/usecases/verify_location_for_task_usecase.dart';
import '../../domain/usecases/watch_challenge_progress_usecase.dart';


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
  final StartChallengeUseCase _startChallengeUseCase;
  final WatchChallengeProgressUseCase _watchChallengeProgressUseCase;
  final UpdateTaskProgressUseCase _updateTaskProgressUseCase;
  final ToggleCheckboxTaskUseCase _toggleCheckboxTaskUseCase;
  final RefreshStepsForTaskUseCase _refreshStepsForTaskUseCase;
  final VerifyLocationForTaskUseCase _verifyLocationForTaskUseCase;
  final SelectImageForTaskUseCase _selectImageForTaskUseCase;

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
  ChallengeProgressEntity? _currentChallengeProgress;
  StreamSubscription? _challengeProgressSubscription;
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

  int? _verifyingTaskIndex;

  ChallengeProvider({
    required GetAllChallengesStreamUseCase getAllChallengesStreamUseCase,
    required GetChallengeByIdUseCase getChallengeByIdUseCase,
    required CreateChallengeUseCase createChallengeUseCase,
    required SearchLocationUseCase searchLocationUseCase,
    required GetLlmFeedbackUseCase getLlmFeedbackUseCase,
    required AcceptChallengeUseCase acceptChallengeUseCase,
    required CompleteChallengeUseCase completeChallengeUseCase,
    required RemoveChallengeFromOngoingUseCase removeChallengeFromOngoingUseCase,
    required StartChallengeUseCase startChallengeUseCase,
    required WatchChallengeProgressUseCase watchChallengeProgressUseCase,
    required UpdateTaskProgressUseCase updateTaskProgressUseCase,
    required ToggleCheckboxTaskUseCase toggleCheckboxTaskUseCase,
    required RefreshStepsForTaskUseCase refreshStepsForTaskUseCase,
    required VerifyLocationForTaskUseCase verifyLocationForTaskUseCase,
    required SelectImageForTaskUseCase selectImageForTaskUseCase,
  })  : _getAllChallengesStreamUseCase = getAllChallengesStreamUseCase,
        _getChallengeByIdUseCase = getChallengeByIdUseCase,
        _createChallengeUseCase = createChallengeUseCase,
        _searchLocationUseCase = searchLocationUseCase,
        _getLlmFeedbackUseCase = getLlmFeedbackUseCase,
        _acceptChallengeUseCase = acceptChallengeUseCase,
        _completeChallengeUseCase = completeChallengeUseCase,
        _removeChallengeFromOngoingUseCase = removeChallengeFromOngoingUseCase,
        _startChallengeUseCase = startChallengeUseCase,
        _watchChallengeProgressUseCase = watchChallengeProgressUseCase,
        _updateTaskProgressUseCase = updateTaskProgressUseCase,
        _toggleCheckboxTaskUseCase = toggleCheckboxTaskUseCase,
        _refreshStepsForTaskUseCase = refreshStepsForTaskUseCase,
        _verifyLocationForTaskUseCase = verifyLocationForTaskUseCase,
        _selectImageForTaskUseCase = selectImageForTaskUseCase {
    _initializeStreams();
  }

  // --- Getters für die UI ---
  bool isVerifyingTask(int index) => _verifyingTaskIndex == index;

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

  ChallengeProgressEntity? get currentChallengeProgress => _currentChallengeProgress;





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

// In: lib/features/challenges/presentation/providers/challenge_provider.dart

  Future<void> fetchChallengeDetails(String challengeId) async {
    // OPTIMALE LÖSUNG: Prüfen, ob bereits die richtige Challenge geladen wird.
    // Verhindert unnötige Ladevorgänge, wenn man schnell hin und her klickt.
    if (_isLoadingSelectedChallenge && _selectedChallenge?.id == challengeId) {
      return;
    }

    // 1. SOFORT den alten Zustand löschen und Ladezustand aktivieren.
    _isLoadingSelectedChallenge = true;
    _selectedChallenge = null; // <-- Der entscheidende Schritt!
    _selectedChallengeError = null;
    _currentChallengeProgress = null;
    _challengeProgressSubscription?.cancel();
    notifyListeners(); // UI sofort anweisen, einen Ladekreis anstelle der alten Daten zu zeigen.

    // 2. Jetzt erst die neuen Daten laden.
    final newChallenge = await _getChallengeByIdUseCase(challengeId);

    // 3. Nach dem Laden den neuen Zustand setzen.
    _selectedChallenge = newChallenge;

    if (_selectedChallenge == null) {
      _selectedChallengeError = "Challenge not found or failed to load.";
      _isLoadingSelectedChallenge = false;
      notifyListeners();
      return;
    }

    // 4. Den Fortschritts-Stream für die neue Challenge starten.
    final userId = _authProvider.currentUserId;
    if (userId != null) {
      final progressId = '${userId}_${_selectedChallenge!.id}';
      _challengeProgressSubscription =
          _watchChallengeProgressUseCase(progressId).listen((progress) {
            _currentChallengeProgress = progress;
            notifyListeners();
          });
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

  /// Akzeptiert die aktuell im Provider geladene Challenge.
  /// Diese Methode ist für die Detailseite gedacht.
  Future<void> acceptCurrentChallenge() async {
    if (_selectedChallenge == null) {
      AppLogger.warning("acceptCurrentChallenge called, but _selectedChallenge is null.");
      return;
    }
    // Ruft die allgemeinere Methode mit der ID der aktuellen Challenge auf.
    await acceptChallengeById(_selectedChallenge!.id);
  }

  /// Akzeptiert eine Challenge anhand ihrer ID.
  /// Diese Methode ist nützlich für Listenansichten oder andere Kontexte,
  /// in denen du nur die ID hast.
  Future<void> acceptChallengeById(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      AppLogger.error("Cannot accept challenge, user is not logged in.");
      return;
    }

    // Finde die vollständige Challenge-Entität, da der StartChallengeUseCase sie benötigt.
    // Wir nehmen sie aus der bereits geladenen Liste aller Challenges.
    final challengeToStart = _allChallenges.firstWhereOrNull((c) => c.id == challengeId);

    if (challengeToStart == null) {
      AppLogger.error("Cannot accept challenge, challenge with ID $challengeId not found.");
      return;
    }

    // 1. Ruft den UseCase auf, um die ID zur "ongoing"-Liste im User-Profil hinzuzufügen.
    // (Dieser Schritt ist für deine Filterung in der Listenansicht wichtig)
    await _acceptChallengeUseCase(UserTaskParams(userId: userId, challengeId: challengeId));

    // 2. Ruft den NEUEN UseCase auf, um das Fortschritts-Dokument in Firestore zu erstellen.
    final params = StartChallengeParams(userId: userId, challenge: challengeToStart);
    await _startChallengeUseCase(params);

    // Die UI wird durch die Streams automatisch auf den neuesten Stand gebracht.
    // Ein explizites notifyListeners() ist hier nicht nötig.
  }

  /// Schließt die aktuell im Provider geladene Challenge ab.
  /// Führt eine Vorab-Prüfung durch und ruft dann die `ById`-Methode auf.
  Future<bool> completeCurrentChallenge() async {
    // Sicherheits-Check: Ist eine Challenge geladen?
    if (_selectedChallenge == null) {
      AppLogger.warning("completeCurrentChallenge called but _selectedChallenge is null.");
      _userChallengeStatusError = "Keine Challenge ausgewählt.";
      notifyListeners();
      return false;
    }

    // Kernlogik-Check: Sind alle Aufgaben erledigt?
    if (_currentChallengeProgress == null ||
        !_currentChallengeProgress!.taskStates.values.every((task) => task.isCompleted)) {
      _userChallengeStatusError = "Du hast noch nicht alle Aufgaben erledigt!";
      notifyListeners();
      AppLogger.warning("Attempted to complete challenge, but not all tasks are done.");
      Timer(const Duration(seconds: 3), () { _userChallengeStatusError = null; notifyListeners(); });
      return false;
    }

    return await completeChallengeById(_selectedChallenge!.id);
  }

  /// Enthält die Kernlogik zum Abschließen einer Challenge anhand ihrer ID.
  Future<bool> completeChallengeById(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "User not logged in.";
      notifyListeners();
      return false;
    }

    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _completeChallengeUseCase(
        CompleteChallengeParams(userId: userId, challengeId: challengeId)
    );

    _isUpdatingUserChallengeStatus = false;
    if (!success) {
      _userChallengeStatusError = "Could not mark challenge as completed.";
    }
    notifyListeners();
    return success;
  }

  /// Aktualisiert den Zustand einer bestimmten Aufgabe.
  Future<void> updateTaskStatus(int taskIndex, bool isCompleted, {dynamic value}) async {
    if (_currentChallengeProgress == null) return;

    final params = UpdateTaskProgressParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
      isCompleted: isCompleted,
      newValue: value,
    );
    await _updateTaskProgressUseCase(params);
  }

  /// Entfernt die aktuell geladene Challenge aus der "Ongoing"-Liste des Nutzers.
  Future<bool> removeCurrentChallengeFromOngoing() async {
    if (_selectedChallenge == null) {
      AppLogger.warning("removeCurrentChallengeFromOngoing called but _selectedChallenge is null.");
      _userChallengeStatusError = "Keine Challenge ausgewählt.";
      notifyListeners();
      return false;
    }
    return await removeChallengeFromOngoingById(_selectedChallenge!.id);
  }

  /// Enthält die Kernlogik zum Entfernen einer Challenge aus "Ongoing" anhand ihrer ID.
  Future<bool> removeChallengeFromOngoingById(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _userChallengeStatusError = "User not logged in.";
      notifyListeners();
      return false;
    }

    _isUpdatingUserChallengeStatus = true;
    _userChallengeStatusError = null;
    notifyListeners();

    final success = await _removeChallengeFromOngoingUseCase(
        UserTaskParams(userId: userId, challengeId: challengeId)
    );

    _isUpdatingUserChallengeStatus = false;
    if (!success) {
      _userChallengeStatusError = "Could not remove challenge from 'Ongoing'.";
    }
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

  /// **1. Für Checkbox-Aufgaben**
  /// Schaltet den Zustand einer Checkbox-Aufgabe um.
  Future<void> toggleCheckboxTask(int taskIndex, bool isCompleted) async {
    if (_currentChallengeProgress == null) return;

    final params = ToggleCheckboxParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
      isCompleted: isCompleted,
    );
    await _toggleCheckboxTaskUseCase(params);
  }

  /// **2. Für Schrittzähler-Aufgaben**
  /// Holt die aktuellen Schritte vom Health-Service und aktualisiert den Fortschritt.
  Future<void> refreshStepCounterTask(int taskIndex) async {
    if (_currentChallengeProgress == null || _selectedChallenge == null) return;

    _verifyingTaskIndex = taskIndex;
    notifyListeners();

    final params = RefreshStepsParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
      taskDefinition: _selectedChallenge!.tasks[taskIndex],
    );

    try {
      await _refreshStepsForTaskUseCase(params);
    } catch (e) {
      _userChallengeStatusError = "Schritte konnten nicht aktualisiert werden. Bitte Berechtigungen prüfen.";
    }

    _verifyingTaskIndex = null;
    notifyListeners();
  }

  /// **3. Für Standort-Aufgaben**
  /// Prüft den aktuellen Standort des Nutzers gegen das Ziel der Aufgabe.
  Future<void> verifyLocationForTask(int taskIndex) async {
    if (_currentChallengeProgress == null || _selectedChallenge == null) return;

    _verifyingTaskIndex = taskIndex; // Setze den Index der ladenden Aufgabe
    notifyListeners();

    final params = VerifyLocationParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
      taskDefinition: _selectedChallenge!.tasks[taskIndex],
    );

    final bool success = await _verifyLocationForTaskUseCase(params);

    if (!success) {
      _userChallengeStatusError = "Du bist nicht am richtigen Ort.";
      // Optional: Fehlermeldung nach einiger Zeit ausblenden
      Timer(const Duration(seconds: 3), () { _userChallengeStatusError = null; notifyListeners(); });
    }

    _verifyingTaskIndex = null;
    notifyListeners();
  }

  /// **4. Für Bild-Aufgaben (simulierter Upload)**
  /// Öffnet die Galerie und speichert den lokalen Pfad des Bildes als Beweis.
  Future<void> selectImageForTask(int taskIndex) async {
    if (_currentChallengeProgress == null) return;

    _verifyingTaskIndex = taskIndex;
    notifyListeners();

    final params = SelectImageParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
    );

    await _selectImageForTaskUseCase(params);

    _verifyingTaskIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _allChallengesSubscription?.cancel();
    _pageController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}