import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

// Core & Auth
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Domain & Entities
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/watch_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_data_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../../domain/usecases/get_profile_stats_pie_chart_usecase.dart';

/// Manages the state for the current user's profile.
///
/// This provider is responsible for:
/// - Subscribing to the user's profile data based on their auth state.
/// - Providing methods to update the profile (text data and image).
/// - Fetching profile-related statistics like chart data.
/// It is designed to be updated by a `ChangeNotifierProxyProvider` that watches
/// the `AuthenticationProvider`.
class UserProfileProvider with ChangeNotifier {
  // --- UseCases ---
  final GetUserProfileUseCase _getUserProfileUseCase;
  final WatchUserProfileUseCase _watchUserProfileUseCase;
  final UpdateProfileDataUseCase _updateProfileDataUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final GetCategoryCountsStream _getProfileStatsPieChartUseCase;

  // --- State ---
  UserProfileEntity? _userProfile;
  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  String? _profileError;
  Stream<Map<String, int>?> _categoryCountsStream = Stream.value(null);

  /// The provider's "memory" of the current user's ID.
  String? _currentUserId;

  // --- Subscriptions ---
  StreamSubscription<UserProfileEntity?>? _userProfileSubscription;

  /// The constructor is simple and only requires its own UseCases.
  UserProfileProvider({
    required GetUserProfileUseCase getUserProfileUseCase,
    required WatchUserProfileUseCase watchUserProfileUseCase,
    required UpdateProfileDataUseCase updateProfileDataUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required GetCategoryCountsStream getProfileStatsPieChartUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _watchUserProfileUseCase = watchUserProfileUseCase,
        _updateProfileDataUseCase = updateProfileDataUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase,
        _getProfileStatsPieChartUseCase = getProfileStatsPieChartUseCase {
    AppLogger.debug("UserProfileProvider: Instance created.");
  }

  // --- Getters for the UI ---
  UserProfileEntity? get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get profileError => _profileError;
  Stream<Map<String, int>?> get categoryCountsStream => _categoryCountsStream;

  // --- Dependency Update Method ---

  /// The gateway for receiving updates from the `AuthenticationProvider`.
  void updateDependencies(AuthenticationProvider authProvider) {
    final newUserId = authProvider.currentUserId;

    // 1. Compare the new user ID with the provider's internal "memory".
    if (newUserId != _currentUserId) {
      // 2. Update the internal memory.
      _currentUserId = newUserId;
      AppLogger.debug("UserProfileProvider: Auth dependency updated. New User ID: $newUserId");

      // 3. React to the change based on the new internal state.
      if (_currentUserId != null) {
        _initializeForUser(_currentUserId!);
      } else {
        _resetState();
      }
    }
  }

  // --- Private Methods for State Management ---

  /// Subscribes to all profile-related data for the given user.
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
    notifyListeners(); // Notify about the new stream for stats
  }

  /// Resets all data, for example on logout.
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

  // --- Public Methods for UI Interaction ---

  /// Manually fetches the user profile once.
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

    String? finalImageUrl = _userProfile?.profileImageUrl;
    bool success = true;

    // 1. Handle image upload if a new file is provided
    if (imageFileToUpload != null) {
      final uploadedUrl = await _uploadProfileImageUseCase(UploadProfileImageParams(
        userId: userId,
        imageFile: imageFileToUpload,
        oldImageUrl: _userProfile?.profileImageUrl,
      ));

      if (uploadedUrl == null) {
        _profileError = "Image upload failed.";
        success = false;
      } else {
        finalImageUrl = uploadedUrl;
      }
    }

    // 2. Update text data if the image step was successful (or skipped)
    if (success) {
      success = await _updateProfileDataUseCase(UpdateProfileDataParams(
        userId: userId, name: name, age: age, studyField: studyField, school: school,
      ));
      if (!success) {
        _profileError = "Failed to update profile data.";
      }
    }

    // The stream from `watchUserProfileUseCase` will eventually deliver the
    // updated profile. An optimistic update could be done here for instant UI feedback,
    // but we rely on the stream for consistency.

    _isUpdatingProfile = false;
    if(!success) notifyListeners(); // Notify if there was an error
    return success;
  }

  @override
  void dispose() {
    AppLogger.debug("UserProfileProvider: Disposing.");
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}