import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_profile_model.dart';

// --- Interface Definition ---
/// Abstract class for remote data operations related to user profiles.
abstract class ProfileRemoteDataSource {
  /// Fetches the [UserProfileModel] for a given [userId].
  /// Throws an [Exception] on failure.
  Future<UserProfileModel?> getUserProfile(String userId);

  /// Provides a stream of [DocumentSnapshot] for a user document.
  /// The stream itself can emit errors.
  Stream<DocumentSnapshot> watchUserProfile(String userId);

  /// Updates specific fields in the user document.
  /// [data] is a map of fields to update and their new values.
  /// Throws an [Exception] on failure.
  Future<void> updateUserProfileData(String userId, Map<String, dynamic> data);

  /// Uploads a profile image to Firebase Storage.
  /// Returns the download URL of the uploaded image.
  /// Throws an [Exception] on failure.
  Future<String> uploadProfileImage(String userId, File imageFile);

  /// Deletes an image from Firebase Storage using its URL.
  /// Errors are handled internally (logged only).
  Future<void> deleteOldProfileImage(String imageUrl);

  /// Adds a [challengeId] to the user's 'ongoingTasks' list.
  /// Throws an [Exception] on failure.
  Future<void> addUserOngoingTask(String userId, String challengeId);

  /// Removes a [challengeId] from the user's 'ongoingTasks' list.
  /// Throws an [Exception] on failure.
  Future<void> removeUserOngoingTask(String userId, String challengeId);

  /// Fetches the user document within a Firestore transaction.
  /// Used by the repository for atomic read-write operations.
  /// Throws an [Exception] on failure.
  Future<DocumentSnapshot> getUserDocumentForTransaction(String userId, Transaction transaction);

  /// Runs a Firestore transaction to update multiple fields of the user document.
  /// Used by the repository for atomic updates after complex calculations.
  /// [userId] is the ID of the user whose profile is to be updated.
  /// [updateFunction] is a callback that receives the [Transaction] and [DocumentReference]
  /// and should return a [Future] with the result of the transaction.
  /// Returns the result of the [updateFunction].
  /// Throws an [Exception] if the transaction fails.
  Future<T> runUserProfileTransaction<T>({
    required String userId,
    required Future<T> Function(Transaction transaction, DocumentReference userDocRef) updateFunction,
  });
}

// --- Implementierung ---
/// Implementation of [ProfileRemoteDataSource] using Firebase services.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Creates an instance of [ProfileRemoteDataSourceImpl].
  /// Requires [firestore] and [storage] instances.
  ProfileRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    if (userId.isEmpty) throw ArgumentError('UserId cannot be empty for getUserProfile.');
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data()!, doc.id);
      }
      AppLogger.info("ProfileRemoteDS: User document for $userId not found");
      return null;
    } catch (e) {
      AppLogger.error("ProfileRemoteDS: getUserProfile error for $userId", e);
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Stream<DocumentSnapshot> watchUserProfile(String userId) {
    if (userId.isEmpty) {
      AppLogger.warning("ProfileRemoteDS: userId is empty for watchUserProfile. Returning empty stream");
      return Stream.error(ArgumentError('UserId cannot be empty for watchUserProfile.'));
    }
    return _firestore.collection('users').doc(userId).snapshots();
  }

  @override
  Future<void> updateUserProfileData(String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty) throw ArgumentError('UserId cannot be empty for updateUserProfileData.');
    if (data.isEmpty) {
      AppLogger.debug("ProfileRemoteDS: No data to update for user $userId");
      return;
    }
    try {
      await _firestore.collection('users').doc(userId).update(data);
      AppLogger.info("ProfileRemoteDS: Profile data updated for user $userId");
    } catch (e) {
      AppLogger.error("ProfileRemoteDS: updateUserProfileData error for $userId", e);
      throw Exception('Failed to update user profile data: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    if (userId.isEmpty) throw ArgumentError('UserId cannot be empty for uploadProfileImage.');
    try {
      final refName = 'profile_images/$userId.jpg'; // Unique name, overwrites old image with the same name
      final storageRef = _storage.ref().child(refName);
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      AppLogger.info("ProfileRemoteDS: Profile image uploaded for user $userId: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      AppLogger.error("ProfileRemoteDS: uploadProfileImage error for $userId", e);
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOldProfileImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    // Check if it's a Firebase Storage URL to avoid errors with other URLs
    if (!imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      AppLogger.warning("ProfileRemoteDS: Invalid URL for deletion: $imageUrl");
      return;
    }
    try {
      await _storage.refFromURL(imageUrl).delete();
      AppLogger.info("ProfileRemoteDS: Old profile image deleted: $imageUrl");
    } catch (e) {
      // Errors when deleting the old image are often not considered critical,
      // so only log and don't necessarily rethrow an exception.
      AppLogger.warning('ProfileRemoteDS: Error deleting old profile image ($imageUrl)', e);
    }
  }

  @override
  Future<void> addUserOngoingTask(String userId, String challengeId) async {
    if (userId.isEmpty || challengeId.isEmpty) throw ArgumentError('UserId or ChallengeId cannot be empty.');
    try {
      await _firestore.collection('users').doc(userId).update({
        'ongoingTasks': FieldValue.arrayUnion([challengeId]),
      });
      AppLogger.info("ProfileRemoteDS: Task $challengeId added to ongoing for user $userId");
    } catch (e) {
      AppLogger.error("ProfileRemoteDS: addUserOngoingTask error for $userId", e);
      throw Exception('Failed to add ongoing task: ${e.toString()}');
    }
  }

  @override
  Future<void> removeUserOngoingTask(String userId, String challengeId) async {
    if (userId.isEmpty || challengeId.isEmpty) throw ArgumentError('UserId or ChallengeId cannot be empty.');
    try {
      await _firestore.collection('users').doc(userId).update({
        'ongoingTasks': FieldValue.arrayRemove([challengeId]),
      });
      AppLogger.info("ProfileRemoteDS: Task $challengeId removed from ongoing for user $userId");
    } catch (e) {
      AppLogger.error("ProfileRemoteDS: removeUserOngoingTask error for $userId", e);
      throw Exception('Failed to remove ongoing task: ${e.toString()}');
    }
  }

  @override
  Future<DocumentSnapshot> getUserDocumentForTransaction(String userId, Transaction transaction) async {
    if (userId.isEmpty) throw ArgumentError('UserId cannot be empty for getUserDocumentForTransaction.');
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    return await transaction.get(userRef);
  }

  @override
  Future<T> runUserProfileTransaction<T>({
    required String userId,
    required Future<T> Function(Transaction transaction, DocumentReference userDocRef) updateFunction,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('UserId cannot be empty for runUserProfileTransaction.');
    }
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    try {
      return await _firestore.runTransaction<T>((transaction) async {
        return await updateFunction(transaction, userRef);
      });
    } catch (e) {
      AppLogger.error("ProfileRemoteDS: Transaction error for user $userId", e);
      throw Exception('Transaction failed for user $userId: ${e.toString()}');
    }
  }
}
