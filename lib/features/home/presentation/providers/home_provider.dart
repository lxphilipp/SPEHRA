import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:collection/collection.dart'; // For deep list comparison

// Core imports
import '/core/utils/app_logger.dart';

// Dependencies: Providers and Entities
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '/features/challenges/domain/entities/challenge_progress_entity.dart';
import '/features/challenges/presentation/providers/challenge_provider.dart';
import '/features/challenges/domain/entities/challenge_entity.dart';
import '/features/sdg/presentation/providers/sdg_list_provider.dart';
import '/features/sdg/domain/entities/sdg_list_item_entity.dart';

// Use Cases
import '../../domain/usecases/get_ongoing_challenge_previews_usecase.dart';
import '../../domain/usecases/get_completed_challenge_previews_usecase.dart';

/// Manages the state for the Home Screen.
///
/// This provider acts as a "view model" for the home screen, aggregating data from
/// multiple other providers to provide a single source of truth for the UI.
/// It is designed to be updated by a `ChangeNotifierProxyProvider4`.
class HomeProvider with ChangeNotifier {
  // --- UseCases ---
  final GetOngoingChallengePreviewsUseCase _getOngoingChallengePreviewsUseCase;
  final GetCompletedChallengePreviewsUseCase _getCompletedChallengePreviewsUseCase;

  // --- Internal Provider References ---
  // These will be kept up-to-date by the `updateDependencies` method.
  late SdgListProvider _sdgListProvider;

  // --- State for Challenge Previews ---
  List<ChallengeEntity> _ongoingChallengePreviews = [];
  bool _isLoadingOngoingPreviews = false;
  String? _ongoingPreviewsError;

  List<ChallengeEntity> _completedChallengePreviews = [];
  bool _isLoadingCompletedPreviews = false;
  String? _completedPreviewsError;

  // Keep track of the last profile state we reacted to, to avoid redundant fetches.
  List<ChallengeProgressEntity>? _lastProcessedProgress;

  /// The constructor is now simple and only requires its own UseCases.
  HomeProvider({
    required GetOngoingChallengePreviewsUseCase getOngoingChallengePreviewsUseCase,
    required GetCompletedChallengePreviewsUseCase getCompletedChallengePreviewsUseCase,
  })  : _getOngoingChallengePreviewsUseCase = getOngoingChallengePreviewsUseCase,
        _getCompletedChallengePreviewsUseCase = getCompletedChallengePreviewsUseCase {
    AppLogger.debug("HomeProvider: Instance created.");
  }

  // --- Getters for UI ---

  // Delegated getters for SDG Navigation Items
  List<SdgListItemEntity> get sdgNavItems => _sdgListProvider.sdgListItems;
  bool get isLoadingSdgItems => _sdgListProvider.isLoading;
  String? get sdgItemsError => _sdgListProvider.error;

  // Getters for Challenge Previews
  List<ChallengeEntity> get ongoingChallengePreviews => _ongoingChallengePreviews;
  bool get isLoadingOngoingPreviews => _isLoadingOngoingPreviews;
  String? get ongoingPreviewsError => _ongoingPreviewsError;

  List<ChallengeEntity> get completedChallengePreviews => _completedChallengePreviews;
  bool get isLoadingCompletedPreviews => _isLoadingCompletedPreviews;
  String? get completedPreviewsError => _completedPreviewsError;

  // --- Dependency Update Method ---

  /// The gateway for receiving updates from all dependency providers.
  /// Called by `ChangeNotifierProxyProvider4`.
  void updateDependencies(
      AuthenticationProvider auth,
      UserProfileProvider profile,
      ChallengeProvider challenges,
      SdgListProvider sdg,
      ) {
    // 1. Update internal references
    _sdgListProvider = sdg;

    // 2. React to meaningful changes.
    // The previews are derived from the user's participations, so we refetch
    // only when that list changes. The `ProxyProvider` calls this method
    // whenever any dependency notifies, hence the equality check.
    final newProgress = auth.isLoggedIn ? challenges.userProgress : null;
    if (!const DeepCollectionEquality().equals(newProgress, _lastProcessedProgress)) {
      AppLogger.debug("HomeProvider: user participations changed. Updating previews.");

      _lastProcessedProgress = newProgress;

      if (newProgress != null) {
        _fetchChallengePreviews(userProgress: newProgress);
      } else {
        // Clear data if user logs out or profile becomes null
        _ongoingChallengePreviews = [];
        _completedChallengePreviews = [];
        _ongoingPreviewsError = null;
        _completedPreviewsError = null;
        notifyListeners();
      }
    }
  }

  // --- Private Methods ---

  Future<void> _fetchChallengePreviews({required List<ChallengeProgressEntity> userProgress}) async {
    const int previewLimit = 3;

    // Fetch Ongoing Challenges
    _isLoadingOngoingPreviews = true;
    _ongoingPreviewsError = null;
    notifyListeners();

    final ongoingResult = await _getOngoingChallengePreviewsUseCase(
        userProgress: userProgress, limit: previewLimit
    );
    _ongoingChallengePreviews = ongoingResult ?? [];
    if (ongoingResult == null) _ongoingPreviewsError = "Could not load ongoing challenges.";
    _isLoadingOngoingPreviews = false;
    notifyListeners(); // Notify after first fetch is complete

    // Fetch Completed Challenges
    _isLoadingCompletedPreviews = true;
    _completedPreviewsError = null;
    notifyListeners();

    final completedResult = await _getCompletedChallengePreviewsUseCase(
        userProgress: userProgress, limit: previewLimit
    );
    _completedChallengePreviews = completedResult ?? [];
    if (completedResult == null) _completedPreviewsError = "Could not load completed challenges.";
    _isLoadingCompletedPreviews = false;
    notifyListeners(); // Final notification
  }
}