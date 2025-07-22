// lib/features/profile/data/datasources/profile_stats_datasource.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';

abstract class ProfileStatsDataSource {
  Stream<List<String>?> getCompletedTaskIdsStream(String userId);
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
        // --- DEBUG CHECKPOINT 1 ---
        if (!snapshot.exists || snapshot.data() == null) {
          AppLogger.info("DEBUG (DataSource): User document for $userId not found or empty.");
          return <String>[];
        }
        final data = snapshot.data();
        final completedTasks = data?['completedTasks'];
        AppLogger.debug("DEBUG (DataSource): Read 'completedTasks' field. Type: ${completedTasks.runtimeType}, Value: $completedTasks");

        if (completedTasks is List) {
          return List<String>.from(completedTasks);
        }
        return <String>[];
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

    const batchSize = 30;
    final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];

    for (int i = 0; i < taskIds.length; i += batchSize) {
      final end = (i + batchSize < taskIds.length) ? i + batchSize : taskIds.length;
      final batchIds = taskIds.sublist(i, end);

      if (batchIds.isNotEmpty) {
        // --- DEBUG CHECKPOINT 2 ---
        AppLogger.debug("DEBUG (DataSource): Querying 'challenges' collection with IDs: $batchIds");
        final query = _firestore
            .collection('challenges')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        futures.add(query);
      }
    }

    try {
      final snapshots = await Future.wait(futures);

      final List<Map<String, dynamic>> results = [];
      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          if (doc.exists) {
            results.add(doc.data());
          }
        }
      }
      // --- DEBUG CHECKPOINT 3 ---
      AppLogger.debug("DEBUG (DataSource): Total challenges found: ${results.length}.");
      return results;
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