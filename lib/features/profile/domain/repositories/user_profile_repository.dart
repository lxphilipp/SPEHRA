import 'dart:io';
import '../entities/user_profile_entity.dart';

/// Abstract class for user profile related operations.
/// This class defines the contract for fetching, updating, and managing user profile data.
abstract class UserProfileRepository {
  /// Fetches the user profile for the given [userId].
  ///
  /// Returns a [UserProfileEntity] if found, otherwise null.
  Future<UserProfileEntity?> getUserProfile(String userId);

  /// Watches the user profile for the given [userId] for real-time updates.
  ///
  /// Returns a [Stream] of [UserProfileEntity] which emits new data when the profile changes.
  Stream<UserProfileEntity?> watchUserProfile(String userId);

  /// Updates the profile data for the given [userId].
  ///
  /// Takes [name], [age], [studyField], [school], and optionally [hasCompletedIntro]
  /// as parameters to update the profile.
  /// Returns true if the update was successful, false otherwise.
  Future<bool> updateProfileData({
    required String userId,
    required String name,
    required int age,
    required String studyField,
    required String school,
    bool? hasCompletedIntro,
  });

  /// Uploads a new profile image and updates the user's profile.
  ///
  /// Takes [userId], the [imageFile] to upload, and an optional [oldImageUrl]
  /// (to delete the old image from storage if provided).
  /// Returns the URL of the uploaded image if successful, otherwise null.
  Future<String?> uploadAndUpdateProfileImage({
    required String userId,
    required File imageFile,
    String? oldImageUrl,
  });

  /// Retrieves a stream of SDG category counts for the given [userId].
  ///
  /// The map contains SDG category names as keys and their respective counts as values.
  /// Returns a [Stream] of [Map<String, int>] or null if not available.
  Stream<Map<String, int>?> getSdgCategoryCountsStream(String userId);

  /// Adds a task to the user's list of ongoing tasks.
  ///
  /// Takes [userId] and [challengeId] to identify the user and the task.
  /// Returns true if the task was successfully added, false otherwise.
  Future<bool> addTaskToOngoing(String userId, String challengeId);

  /// Removes a task from the user's list of ongoing tasks.
  ///
  /// Takes [userId] and [challengeId] to identify the user and the task.
  /// Returns true if the task was successfully removed, false otherwise.
  Future<bool> removeTaskFromOngoing(String userId, String challengeId);

  /// Marks a task as completed for the user.
  ///
  /// Takes [userId], [challengeId], and [pointsEarned] for completing the task.
  /// Returns true if the task was successfully marked as completed, false otherwise.
  Future<bool> markTaskAsCompleted({
    required String userId,
    required String challengeId,
    required int pointsEarned,
  });

  /// Adds bonus points to the profiles of the specified users.
  ///
  /// Takes a list of [userIds] and the number of [points] to add.
  Future<void> addBonusPoints({required List<String> userIds, required int points});
}
