import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';

abstract class ProfileStatsDataSource {
  /// Liefert einen Stream der Liste von IDs der abgeschlossenen Challenges eines Benutzers.
  /// Gibt einen Stream mit `null` zurück, wenn ein Fehler beim Zugriff auf die User-Daten auftritt.
  Stream<List<String>?> getCompletedTaskIdsStream(String userId);

  /// Holt die Challenge-Dokumente für eine gegebene Liste von Challenge-IDs.
  /// Gibt eine Liste von Maps (die Challenge-Daten) oder `null` bei einem Fehler zurück.
  /// Beachtet das Firestore 'whereIn'-Limit (typischerweise 10 oder 30).
  Future<List<Map<String, dynamic>>?> getChallengeDetailsForTasks(List<String> taskIds);
}

class ProfileStatsDataSourceImpl implements ProfileStatsDataSource {
  final FirebaseFirestore _firestore;

  ProfileStatsDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<String>?> getCompletedTaskIdsStream(String userId) {
    if (userId.isEmpty) {
      AppLogger.warning("ProfileStatsDS: userId is empty for getCompletedTaskIdsStream");
      return Stream.value(null);
    }
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          AppLogger.info("ProfileStatsDS: User document for $userId not found or empty");
          return <String>[]; // User existiert nicht oder hat keine Tasks, leere Liste ist valide
        }
        // Gib die Liste der completedTasks zurück, oder eine leere Liste falls das Feld fehlt.
        return List<String>.from(snapshot.data()?['completedTasks'] ?? []);
      }).handleError((error) {
        AppLogger.error("ProfileStatsDS: Error in getCompletedTaskIdsStream for user $userId", error);
        return null;
      });
    } catch (e) {
      AppLogger.error("ProfileStatsDS: Synchronous error in getCompletedTaskIdsStream setup for user $userId", e);
      return Stream.value(null);
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> getChallengeDetailsForTasks(List<String> taskIds) async {
    if (taskIds.isEmpty) {
      return [];
    }

    List<String> idsToQuery = taskIds.take(10).toList();
    if (idsToQuery.isEmpty) {
        return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('challenges')
          .where(FieldPath.documentId, whereIn: idsToQuery)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error("ProfileStatsDS: Firebase error in getChallengeDetailsForTasks: ${e.message} (Code: ${e.code})", e);
      return null;
    }
    catch (e) {
      AppLogger.error("ProfileStatsDS: Unexpected error in getChallengeDetailsForTasks", e);
      return null;
    }
  }
}