// lib/features/home/presentation/providers/home_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

// Core imports
import '/core/utils/app_logger.dart';

// Auth, Profile, Challenge Provider und relevante Entities
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '/features/challenges/presentation/providers/challenge_provider.dart';
import '/features/challenges/domain/entities/challenge_entity.dart';

// SDG List Provider und relevante Entity (aus dem sdg-Feature)
import '/features/sdg/presentation/providers/sdg_list_provider.dart';
import '/features/sdg/domain/entities/sdg_list_item_entity.dart';

// Use Cases für die Challenge-Vorschauen (bleiben im home-Feature, da sie spezifisch für Home-Vorschau sind)
import '../../domain/usecases/get_ongoing_challenge_previews_usecase.dart';
import '../../domain/usecases/get_completed_challenge_previews_usecase.dart';

class HomeProvider with ChangeNotifier {
  final GetOngoingChallengePreviewsUseCase _getOngoingChallengePreviewsUseCase;
  final GetCompletedChallengePreviewsUseCase _getCompletedChallengePreviewsUseCase;
  final AuthenticationProvider _authProvider;
  final UserProfileProvider _userProfileProvider;
  final ChallengeProvider _challengeProvider;
  final SdgListProvider _sdgListProvider; // Abhängigkeit zum SdgListProvider
  
  bool _disposed = false;

  HomeProvider({
    required GetOngoingChallengePreviewsUseCase getOngoingChallengePreviewsUseCase,
    required GetCompletedChallengePreviewsUseCase getCompletedChallengePreviewsUseCase,
    required AuthenticationProvider authProvider,
    required UserProfileProvider userProfileProvider,
    required ChallengeProvider challengeProvider,
    required SdgListProvider sdgListProvider, // Wird injiziert
  })  : _getOngoingChallengePreviewsUseCase = getOngoingChallengePreviewsUseCase,
        _getCompletedChallengePreviewsUseCase = getCompletedChallengePreviewsUseCase,
        _authProvider = authProvider,
        _userProfileProvider = userProfileProvider,
        _challengeProvider = challengeProvider,
        _sdgListProvider = sdgListProvider {
    // Listener hinzufügen
    _authProvider.addListener(_onDependenciesChangedForPreviews);
    _userProfileProvider.addListener(_onDependenciesChangedForPreviews);
    _sdgListProvider.addListener(_onSdgDataChanged); // Auf Änderungen im SdgListProvider hören

    // Initiales Laden der Challenge-Previews, wenn User-Daten bereits vorhanden sind
    if (_authProvider.isLoggedIn && _userProfileProvider.userProfile != null) {
      _fetchChallengePreviews();
    }
    // SDG-Items werden vom SdgListProvider selbst geladen (im Konstruktor).
  }

  // --- Getter für SDG Navigation (delegiert an SdgListProvider) ---
  List<SdgListItemEntity> get sdgNavItems => _sdgListProvider.sdgListItems;
  bool get isLoadingSdgItems => _sdgListProvider.isLoading;
  String? get sdgItemsError => _sdgListProvider.error;

  // --- State und Getter für Challenge Previews (bleiben im HomeProvider) ---
  List<ChallengeEntity> _ongoingChallengePreviews = [];
  List<ChallengeEntity> get ongoingChallengePreviews => _ongoingChallengePreviews;
  bool _isLoadingOngoingPreviews = false;
  bool get isLoadingOngoingPreviews => _isLoadingOngoingPreviews;
  String? _ongoingPreviewsError;
  String? get ongoingPreviewsError => _ongoingPreviewsError;

  List<ChallengeEntity> _completedChallengePreviews = [];
  List<ChallengeEntity> get completedChallengePreviews => _completedChallengePreviews;
  bool _isLoadingCompletedPreviews = false;
  bool get isLoadingCompletedPreviews => _isLoadingCompletedPreviews;
  String? _completedPreviewsError;
  String? get completedPreviewsError => _completedPreviewsError;

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _onDependenciesChangedForPreviews() {
    AppLogger.debug("HomeProvider: Auth or UserProfile for Challenge previews has changed");
    if (_authProvider.isLoggedIn && _userProfileProvider.userProfile != null) {
      _fetchChallengePreviews();
    } else {
      _ongoingChallengePreviews = [];
      _completedChallengePreviews = [];
      _ongoingPreviewsError = null;
      _completedPreviewsError = null;
      _safeNotifyListeners();
    }
  }

  void _onSdgDataChanged() {
    AppLogger.debug("HomeProvider: SdgListProvider has changed (SDG Nav Items)");
    _safeNotifyListeners(); // Informiert Widgets, die sdgNavItems etc. verwenden
  }

  Future<void> _fetchChallengePreviews() async {
    if (_disposed) return; // Early return if disposed
    
    final userProfile = _userProfileProvider.userProfile;
    if (!_authProvider.isLoggedIn || userProfile == null) return;

    const int previewLimit = 3;

    // Ongoing Challenges
    _isLoadingOngoingPreviews = true;
    _ongoingPreviewsError = null;
    _safeNotifyListeners();
    final ongoingResult = await _getOngoingChallengePreviewsUseCase(
      userProfile: userProfile, limit: previewLimit
    );
    if (_disposed) return; // Check if disposed after async operation
    
    _ongoingChallengePreviews = ongoingResult ?? [];
    if (ongoingResult == null) _ongoingPreviewsError = "Laufende Challenges konnten nicht geladen werden.";
    _isLoadingOngoingPreviews = false;
    // notifyListeners(); // Wird nach Completed gemacht

    // Completed Challenges
    _isLoadingCompletedPreviews = true;
    _completedPreviewsError = null;
    // notifyListeners();
    final completedResult = await _getCompletedChallengePreviewsUseCase(userProfile: userProfile, limit: previewLimit);
    if (_disposed) return; // Check if disposed after async operation
    
    _completedChallengePreviews = completedResult ?? [];
    if (completedResult == null) _completedPreviewsError = "Abgeschlossene Challenges konnten nicht geladen werden.";
    _isLoadingCompletedPreviews = false;

    _safeNotifyListeners(); // Einmal am Ende für beide Preview-Listen
  }

  // Die Methode fetchSdgNavigationItems() wird im HomeProvider nicht mehr benötigt.

  @override
  void dispose() {
    _disposed = true;
    _authProvider.removeListener(_onDependenciesChangedForPreviews);
    _userProfileProvider.removeListener(_onDependenciesChangedForPreviews);
    _sdgListProvider.removeListener(_onSdgDataChanged);
    super.dispose();
  }
}