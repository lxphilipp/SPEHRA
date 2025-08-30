import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_profile_model.dart';

// --- Interface Definition ---
abstract class ProfileRemoteDataSource {
  /// Holt das UserProfileModel für eine gegebene userId.
  /// Wirft eine Exception bei Fehlern.
  Future<UserProfileModel?> getUserProfile(String userId);

  /// Liefert einen Stream von DocumentSnapshots für ein User-Dokument.
  /// Der Stream selbst kann Fehler enthalten.
  Stream<DocumentSnapshot> watchUserProfile(String userId);

  /// Aktualisiert spezifische Felder im User-Dokument.
  /// `data` ist eine Map der zu aktualisierenden Felder und ihrer neuen Werte.
  /// Wirft eine Exception bei Fehlern.
  Future<void> updateUserProfileData(String userId, Map<String, dynamic> data);

  /// Lädt ein Bild in Firebase Storage hoch.
  /// Gibt die Download-URL des hochgeladenen Bildes zurück.
  /// Wirft eine Exception bei Fehlern.
  Future<String> uploadProfileImage(String userId, File imageFile);

  /// Löscht ein Bild aus Firebase Storage anhand seiner URL.
  /// Fehler werden intern behandelt (nur geloggt).
  Future<void> deleteOldProfileImage(String imageUrl);

  /// Fügt eine challengeId zur 'ongoingTasks'-Liste des Users hinzu.
  /// Wirft eine Exception bei Fehlern.
  Future<void> addUserOngoingTask(String userId, String challengeId);

  /// Entfernt eine challengeId aus der 'ongoingTasks'-Liste des Users.
  /// Wirft eine Exception bei Fehlern.
  Future<void> removeUserOngoingTask(String userId, String challengeId);

  /// Holt das User-Dokument innerhalb einer Firestore-Transaktion.
  /// Wird vom Repository für atomare Lese-Schreib-Operationen verwendet.
  /// Wirft eine Exception bei Fehlern.
  Future<DocumentSnapshot> getUserDocumentForTransaction(String userId, Transaction transaction);

  /// Aktualisiert mehrere Felder des User-Dokuments innerhalb einer Firestore-Transaktion.
  /// Wird vom Repository für atomare Updates nach komplexen Berechnungen verwendet.
  /// `data` ist eine Map der zu aktualisierenden Felder.
  Future<T> runUserProfileTransaction<T>({
    required String userId,
    required Future<T> Function(Transaction transaction, DocumentReference userDocRef) updateFunction,
  });
}

// --- Implementierung ---
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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
      final refName = 'profile_images/$userId.jpg'; // Eindeutiger Name, überschreibt altes Bild mit gleichem Namen
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
    // Prüfe, ob es eine Firebase Storage URL ist, um Fehler bei anderen URLs zu vermeiden
    if (!imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      AppLogger.warning("ProfileRemoteDS: Invalid URL for deletion: $imageUrl");
      return;
    }
    try {
      await _storage.refFromURL(imageUrl).delete();
      AppLogger.info("ProfileRemoteDS: Old profile image deleted: $imageUrl");
    } catch (e) {
      // Fehler beim Löschen des alten Bildes werden oft nicht als kritisch angesehen,
      // daher nur loggen und nicht unbedingt eine Exception weiterwerfen.
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