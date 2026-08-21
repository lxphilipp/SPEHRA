import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// Core & Auth
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Domain & Entities
import '../../../../core/usecases/use_case.dart';
import '../../../challenges/domain/entities/game_balance_entity.dart';
import '../../../challenges/domain/usecases/get_game_balance_usecase.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/watch_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_data_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../../domain/usecases/get_profile_stats_pie_chart_usecase.dart';
import '../../domain/utils/level_utils.dart';

class UserProfileProvider with ChangeNotifier {
  // --- UseCases ---
  final GetUserProfileUseCase _getUserProfileUseCase;
  final WatchUserProfileUseCase _watchUserProfileUseCase;
  final UpdateProfileDataUseCase _updateProfileDataUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final GetCategoryCountsStream _getProfileStatsPieChartUseCase;
  final GetGameBalanceUseCase _getGameBalanceUseCase;

  // --- State ---
  UserProfileEntity? _userProfile;
  GameBalanceEntity? _gameBalance;
  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  String? _profileError;
  Stream<Map<String, int>?> _categoryCountsStream = Stream.value(null);

  String? _currentUserId;

  // --- Subscriptions ---
  StreamSubscription<UserProfileEntity?>? _userProfileSubscription;
  bool _disposed = false;

  UserProfileProvider({
    required GetUserProfileUseCase getUserProfileUseCase,
    required WatchUserProfileUseCase watchUserProfileUseCase,
    required UpdateProfileDataUseCase updateProfileDataUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required GetCategoryCountsStream getProfileStatsPieChartUseCase,
    required GetGameBalanceUseCase getGameBalanceUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _watchUserProfileUseCase = watchUserProfileUseCase,
        _updateProfileDataUseCase = updateProfileDataUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase,
        _getProfileStatsPieChartUseCase = getProfileStatsPieChartUseCase,
        _getGameBalanceUseCase = getGameBalanceUseCase {
    AppLogger.debug("UserProfileProvider: Instance created.");
    _loadGameBalance();
  }

  // --- Getters for the UI ---
  UserProfileEntity? get userProfile => _userProfile;

  /// The level curve parameters currently in effect, or null while loading.
  GameBalanceEntity? get gameBalance => _gameBalance;

  /// Level, progress and XP thresholds derived from the user's points and the
  /// configured level curve. Null until both the profile and the game balance
  /// are available.
  LevelData? get levelData {
    final profile = _userProfile;
    final balance = _gameBalance;
    if (profile == null || balance == null) return null;
    return LevelUtils.fromBalance(balance).calculateLevelData(profile.points);
  }
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get profileError => _profileError;
  Stream<Map<String, int>?> get categoryCountsStream => _categoryCountsStream;

  Future<void> _loadGameBalance() async {
    try {
      final balance = await _getGameBalanceUseCase(NoParams());
      if (_disposed) return;
      _gameBalance = balance;
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error("UserProfileProvider: Could not load game balance.", e, stackTrace);
    }
  }

  void updateDependencies(AuthenticationProvider authProvider) {
    final newUserId = authProvider.currentUserId;

    if (newUserId != _currentUserId) {
      _currentUserId = newUserId;
      AppLogger.debug("UserProfileProvider: Auth dependency updated. New User ID: $newUserId");

      if (_currentUserId != null) {
        _initializeForUser(_currentUserId!);
      } else {
        _resetState();
      }
    }
  }

  void _initializeForUser(String userId) {
    AppLogger.debug("UserProfileProvider: Initializing profile and stats for user $userId");
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    _userProfileSubscription?.cancel();
    _userProfileSubscription = _watchUserProfileUseCase(userId).listen(
          (profileEntity) {
        _userProfile = profileEntity;
        _isLoadingProfile = false;
        if (profileEntity == null) {
          _profileError = "Could not load profile.";
        } else {
          _profileError = null;
        }
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error("UserProfileProvider: Error in profile stream for $userId", error);
        _profileError = "Error loading profile: ${error.toString()}";
        _userProfile = null;
        _isLoadingProfile = false;
        notifyListeners();
      },
    );

    _categoryCountsStream = _getProfileStatsPieChartUseCase(userId);
    notifyListeners();
  }

  void _resetState() {
    AppLogger.debug("UserProfileProvider: User logged out, resetting state.");
    _userProfile = null;
    _userProfileSubscription?.cancel();
    _userProfileSubscription = null;
    _categoryCountsStream = Stream.value(null);
    _isLoadingProfile = false;
    _isUpdatingProfile = false;
    _profileError = null;
    notifyListeners();
  }

  Future<void> fetchUserProfileManually() async {
    final userId = _currentUserId;
    if (userId == null) {
      _profileError = "Not logged in.";
      notifyListeners();
      return;
    }
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    final profile = await _getUserProfileUseCase(userId);
    _userProfile = profile;
    if (profile == null) {
      _profileError = "Could not manually load profile.";
    }
    _isLoadingProfile = false;
    notifyListeners();
  }

  /// Updates the user's profile data and optionally their profile image.
  Future<bool> updateProfile({
    required String name,
    required int age,
    required String studyField,
    required String school,
    File? imageFileToUpload,
    bool? hasCompletedIntro, // <-- HIER AKTUALISIERT
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      _profileError = "Not logged in.";
      notifyListeners();
      return false;
    }

    _isUpdatingProfile = true;
    _profileError = null;
    notifyListeners();

    bool success = true;

    // Handle image upload if a new file is provided
    if (imageFileToUpload != null) {
      final uploadedUrl = await _uploadProfileImageUseCase(UploadProfileImageParams(
        userId: userId,
        imageFile: imageFileToUpload,
        oldImageUrl: _userProfile?.profileImageUrl,
      ));

      if (uploadedUrl == null) {
        _profileError = "Image upload failed.";
        success = false;
      }
    }

    // Update text data if the image step was successful (or skipped)
    if (success) {
      success = await _updateProfileDataUseCase(UpdateProfileDataParams(
        userId: userId,
        name: name,
        age: age,
        studyField: studyField,
        school: school,
        hasCompletedIntro: hasCompletedIntro,
      ));
      if (!success) {
        _profileError = "Failed to update profile data.";
      }
    }

    _isUpdatingProfile = false;
    if(!success) notifyListeners();
    return success;
  }

  @override
  void dispose() {
    AppLogger.debug("UserProfileProvider: Disposing.");
    _disposed = true;
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}