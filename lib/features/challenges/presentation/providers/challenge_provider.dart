import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart'; // For deep list comparison

// Core & Usecases
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/challenge_progress_entity.dart';
import '../../domain/entities/game_balance_entity.dart';
import '../../domain/usecases/create_challenge_usecase.dart';
import '../../domain/usecases/get_all_challenges_stream_usecase.dart';
import '../../domain/usecases/get_challenge_by_id_usecase.dart';
import '../../domain/usecases/accept_challenge_usecase.dart';
import '../../domain/usecases/complete_challenge_usecase.dart';
import '../../domain/usecases/get_game_balance_usecase.dart';
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


/// Manages all state related to Challenges.
///
/// This class is responsible for:
/// - Providing and filtering the list of all available challenges.
/// - Fetching details for a single, selected challenge.
/// - Managing the state for the multi-step "Challenge Builder".
/// - Interacting with the user profile (accepting, completing challenges).
class ChallengeProvider with ChangeNotifier {
  // --- UseCases from the Domain Layer ---
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
  final GetGameBalanceUseCase _getGameBalanceUseCase;

  // --- Internal References to other Providers ---
  late AuthenticationProvider _authProvider;
  late UserProfileProvider _userProfileProvider;

  // --- State for Challenge List and Filtering ---
  List<ChallengeEntity> _allChallenges = [];
  StreamSubscription? _allChallengesSubscription;
  ChallengeFilterState _filterState = const ChallengeFilterState();
  String _sortCriteria = 'createdAt';
  bool _isSortAscending = false;

  // --- State for Detail View ---
  ChallengeEntity? _selectedChallenge;
  ChallengeProgressEntity? _currentChallengeProgress;
  StreamSubscription? _challengeProgressSubscription;
  bool _isLoadingSelectedChallenge = false;
  String? _selectedChallengeError;

  // --- State for Challenge Builder ---
  ChallengeEntity? _challengeInProgress;
  bool _isCreatingChallenge = false;
  String? _createChallengeError;

  // --- State for User Interactions ---
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

  // --- State for Game Balance ---
  GameBalanceEntity? _gameBalance; // NEW: State for the balance config
  bool _isLoadingBalance = true;

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
    required GetGameBalanceUseCase getGameBalanceUseCase, // NEW: Inject in constructor
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
        _selectImageForTaskUseCase = selectImageForTaskUseCase,
        _getGameBalanceUseCase = getGameBalanceUseCase { // NEW
    _initializeStreams();
    _loadGameBalance(); // NEW: Load balance config on startup
  }

  // --- Getters for the UI ---
  bool isVerifyingTask(int index) => _verifyingTaskIndex == index;
  GameBalanceEntity? get gameBalance => _gameBalance; // NEW: Expose the balance config
  bool get isLoading => _isLoadingBalance || _allChallenges.isEmpty; // isLoading now considers balance loading

  // List and Filter State
  ChallengeFilterState get filterState => _filterState;
  String get sortCriteria => _sortCriteria;
  bool get isSortAscending => _isSortAscending;

  // Detail View State
  ChallengeEntity? get selectedChallenge => _selectedChallenge;
  bool get isLoadingSelectedChallenge => _isLoadingSelectedChallenge;
  String? get selectedChallengeError => _selectedChallengeError;

  // Builder State
  ChallengeEntity? get challengeInProgress => _challengeInProgress;
  bool get isCreatingChallenge => _isCreatingChallenge;
  String? get createChallengeError => _createChallengeError;

  // Interaction State
  bool get isUpdatingUserChallengeStatus => _isUpdatingUserChallengeStatus;
  String? get userChallengeStatusError => _userChallengeStatusError;

  // Feedback State
  bool get isFetchingFeedback => _isFetchingFeedback;
  String? get feedbackError => _feedbackError;
  Map<String, dynamic> get llmFeedbackData => _llmFeedbackData;

  ChallengeProgressEntity? get currentChallengeProgress => _currentChallengeProgress;


  /// Returns the filtered and sorted list of challenges.
  /// The UI should always use this getter.
  List<ChallengeEntity> get filteredChallenges {
    if (_gameBalance == null) return []; // Return empty if balance is not loaded yet

    List<ChallengeEntity> filtered = List.from(_allChallenges);

    // Filtering logic remains the same
    if (_filterState.searchText.isNotEmpty) { /* ... */ }
    if (_filterState.selectedDifficulties.isNotEmpty) {
      filtered = filtered.where((c) => _filterState.selectedDifficulties.contains(c.calculateDifficulty(_gameBalance!))).toList();
    }
    if (_filterState.selectedSdgKeys.isNotEmpty) { /* ... */ }

    // Sorting logic now passes the balance config
    filtered.sort((a, b) {
      int comparison;
      switch (_sortCriteria) {
        case 'points':
          comparison = a.calculatePoints(_gameBalance!).compareTo(b.calculatePoints(_gameBalance!));
          break;
        case 'difficulty':
          const order = {'Easy': 1, 'Normal': 2, 'Advanced': 3, 'Experienced': 4};
          comparison = (order[a.calculateDifficulty(_gameBalance!)] ?? 5).compareTo(order[b.calculateDifficulty(_gameBalance!)] ?? 5);
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

  // --- Methods for state change ---

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
    // OPTIMAL SOLUTION: Check if the correct challenge is already being loaded.
    // Prevents unnecessary loading when clicking back and forth quickly.
    if (_isLoadingSelectedChallenge && _selectedChallenge?.id == challengeId) {
      return;
    }

    // 1. IMMEDIATELY clear the old state and activate loading state.
    _isLoadingSelectedChallenge = true;
    _selectedChallenge = null; // <-- The crucial step!
    _selectedChallengeError = null;
    _currentChallengeProgress = null;
    _challengeProgressSubscription?.cancel();
    notifyListeners(); // Immediately instruct UI to show a loading spinner instead of old data.

    // 2. Now load the new data.
    final newChallenge = await _getChallengeByIdUseCase(challengeId);

    // 3. After loading, set the new state.
    _selectedChallenge = newChallenge;

    if (_selectedChallenge == null) {
      _selectedChallengeError = "Challenge not found or failed to load.";
      _isLoadingSelectedChallenge = false;
      notifyListeners();
      return;
    }

    // 4. Start the progress stream for the new challenge.
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


  // --- Builder Methods ---

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
      _createChallengeError = "No challenge available to save.";
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
      _challengeInProgress = null; // Reset builder after success.
    } else {
      _createChallengeError = "Error saving challenge.";
    }

    notifyListeners();
    return newId;
  }

  // --- User Interaction Methods ---

  /// Navigates to the next page in the PageView.
  void nextPage() {
    if (_pageController == null || !_pageController!.hasClients) return;
    _currentPage++;
    _pageController!.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    notifyListeners();
  }

  /// Navigates to the previous page in the PageView.
  void previousPage() {
    if (_pageController == null || !_pageController!.hasClients) return;
    _currentPage--;
    _pageController!.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    notifyListeners();
  }

  /// Accepts the challenge currently loaded in the provider.
  /// This method is intended for the detail page.
  Future<void> acceptCurrentChallenge() async {
    if (_selectedChallenge == null) {
      AppLogger.warning("acceptCurrentChallenge called, but _selectedChallenge is null.");
      return;
    }
    // Calls the more general method with the ID of the current challenge.
    await acceptChallengeById(_selectedChallenge!.id);
  }

  /// Accepts a challenge by its ID.
  /// This method is useful for list views or other contexts
  /// where you only have the ID.
  Future<void> acceptChallengeById(String challengeId) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      AppLogger.error("Cannot accept challenge, user is not logged in.");
      return;
    }

    // Find the full Challenge entity, as the StartChallengeUseCase requires it.
    // We take it from the already loaded list of all challenges.
    final challengeToStart = _allChallenges.firstWhereOrNull((c) => c.id == challengeId);

    if (challengeToStart == null) {
      AppLogger.error("Cannot accept challenge, challenge with ID $challengeId not found.");
      return;
    }

    // 1. Calls the UseCase to add the ID to the "ongoing" list in the user profile.
    // (This step is important for your filtering in the list view)
    await _acceptChallengeUseCase(UserTaskParams(userId: userId, challengeId: challengeId));

    // 2. Calls the NEW UseCase to create the progress document in Firestore.
    final params = StartChallengeParams(userId: userId, challenge: challengeToStart);
    await _startChallengeUseCase(params);

    // The UI is automatically updated by the streams.
    // An explicit notifyListeners() is not necessary here.
  }

  /// Completes the challenge currently loaded in the provider.
  /// Performs a preliminary check and then calls the `ById` method.
  Future<bool> completeCurrentChallenge() async {
    // Safety check: Is a challenge loaded?
    if (_selectedChallenge == null) {
      AppLogger.warning("completeCurrentChallenge called but _selectedChallenge is null.");
      _userChallengeStatusError = "No challenge selected.";
      notifyListeners();
      return false;
    }

    // Core logic check: Are all tasks completed?
    if (_currentChallengeProgress == null ||
        !_currentChallengeProgress!.taskStates.values.every((task) => task.isCompleted)) {
      _userChallengeStatusError = "You have not completed all tasks yet!";
      notifyListeners();
      AppLogger.warning("Attempted to complete challenge, but not all tasks are done.");
      Timer(const Duration(seconds: 3), () { _userChallengeStatusError = null; notifyListeners(); });
      return false;
    }

    return await completeChallengeById(_selectedChallenge!.id);
  }

  /// Contains the core logic for completing a challenge by its ID.
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

  /// Updates the status of a specific task.
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

  /// Removes the currently loaded challenge from the user's "Ongoing" list.
  Future<bool> removeCurrentChallengeFromOngoing() async {
    if (_selectedChallenge == null) {
      AppLogger.warning("removeCurrentChallengeFromOngoing called but _selectedChallenge is null.");
      _userChallengeStatusError = "No challenge selected.";
      notifyListeners();
      return false;
    }
    return await removeChallengeFromOngoingById(_selectedChallenge!.id);
  }

  /// Contains the core logic for removing a challenge from "Ongoing" by its ID.
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

  /// **1. For Checkbox Tasks**
  /// Toggles the state of a checkbox task.
  Future<void> toggleCheckboxTask(int taskIndex, bool isCompleted) async {
    if (_currentChallengeProgress == null) return;

    final params = ToggleCheckboxParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
      isCompleted: isCompleted,
    );
    await _toggleCheckboxTaskUseCase(params);
  }

  /// **2. For Step Counter Tasks**
  /// Fetches the current steps from the Health Service and updates the progress.
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
      _userChallengeStatusError = "Steps could not be updated. Please check permissions.";
    }

    _verifyingTaskIndex = null;
    notifyListeners();
  }

  /// **3. For Location Tasks**
  /// Checks the user's current location against the task's target.
  Future<void> verifyLocationForTask(int taskIndex) async {
    if (_currentChallengeProgress == null || _selectedChallenge == null) return;

    _verifyingTaskIndex = taskIndex; // Set the index of the loading task
    notifyListeners();

    final params = VerifyLocationParams(
      progressId: _currentChallengeProgress!.id,
      taskIndex: taskIndex,
      taskDefinition: _selectedChallenge!.tasks[taskIndex],
    );

    final bool success = await _verifyLocationForTaskUseCase(params);

    if (!success) {
      _userChallengeStatusError = "You are not at the correct location.";
      // Optional: Hide error message after some time
      Timer(const Duration(seconds: 3), () { _userChallengeStatusError = null; notifyListeners(); });
    }

    _verifyingTaskIndex = null;
    notifyListeners();
  }

  /// **4. For Image Tasks (simulated upload)**
  /// Opens the gallery and saves the local path of the image as proof.
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

  Future<void> _loadGameBalance() async {
    _isLoadingBalance = true;
    notifyListeners();
    _gameBalance = await _getGameBalanceUseCase(NoParams());
    _isLoadingBalance = false;
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