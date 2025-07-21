import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/challenge_progress_model.dart';
import '../models/group_challenge_progress_model.dart';

// --- Extend Interface ---
abstract class ChallengeProgressRemoteDataSource {
  Stream<ChallengeProgressModel?> watchChallengeProgress(String progressId);
  Future<void> createChallengeProgress(ChallengeProgressModel progress);
  Future<void> updateTaskState(String progressId, String taskIndex, Map<String, dynamic> newStateMap);
  Future<void> createGroupProgress(GroupChallengeProgressModel groupProgress);
  Future<GroupChallengeProgressModel?> getGroupProgress(String inviteId);
  Future<void> addParticipantToGroupProgress({required String inviteId, required String userId, required int tasksPerUser});
  Future<GroupChallengeProgressModel?> incrementGroupProgress(String inviteId);
  Future<void> markMilestoneAsAwarded({required String inviteId, required int milestone});
  Stream<List<GroupChallengeProgressModel>> watchGroupProgressByContextId(String contextId);
}

class ChallengeProgressRemoteDataSourceImpl implements ChallengeProgressRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChallengeProgressRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _progressCollection => _firestore.collection('challenge_progress');
  CollectionReference get _groupProgressCollection => _firestore.collection('group_challenge_progress');

  @override
  Future<void> createChallengeProgress(ChallengeProgressModel progress) async {
    await _progressCollection.doc(progress.id).set(progress.toMap());
  }

  @override
  Stream<ChallengeProgressModel?> watchChallengeProgress(String progressId) {
    return _progressCollection.doc(progressId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return ChallengeProgressModel.fromSnapshot(snapshot);
      }
      return null;
    });
  }

  @override
  Future<void> updateTaskState(String progressId, String taskIndex, Map<String, dynamic> newStateMap) async {
    try {
      await _progressCollection.doc(progressId).update({
        'taskStates.$taskIndex': newStateMap,
      });
    } catch (e) {
      throw Exception("Could not update task state: $e");
    }
  }

  @override
  Future<void> createGroupProgress(GroupChallengeProgressModel groupProgress) async {
    await _groupProgressCollection.doc(groupProgress.id).set(groupProgress.toMap());
  }

  @override
  Future<GroupChallengeProgressModel?> getGroupProgress(String inviteId) async {
    final doc = await _groupProgressCollection.doc(inviteId).get();
    if (doc.exists) {
      return GroupChallengeProgressModel.fromSnapshot(doc);
    }
    return null;
  }

  @override
  Future<void> addParticipantToGroupProgress({required String inviteId, required String userId, required int tasksPerUser}) async {
    final docRef = _groupProgressCollection.doc(inviteId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      final currentParticipants = List<String>.from(data['participantIds'] ?? []);
      if (currentParticipants.contains(userId)) return; // User ist schon dabei

      transaction.update(docRef, {
        'participantIds': FieldValue.arrayUnion([userId]),
        'totalTasksRequired': FieldValue.increment(tasksPerUser),
      });
    });
  }

  @override
  Future<GroupChallengeProgressModel?> incrementGroupProgress(String inviteId) async {
    final docRef = _groupProgressCollection.doc(inviteId);

    return _firestore.runTransaction<GroupChallengeProgressModel?>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        AppLogger.warning("Group progress document with id $inviteId not found during transaction.");
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentCount = (data['completedTasksCount'] as num?)?.toInt() ?? 0;
      final newCount = currentCount + 1;

      transaction.update(docRef, {'completedTasksCount': newCount});

      final updatedData = Map<String, dynamic>.from(data);
      updatedData['completedTasksCount'] = newCount;

      return GroupChallengeProgressModel.fromMap(updatedData, snapshot.id);
    });
  }

  @override
  Future<void> markMilestoneAsAwarded({required String inviteId, required int milestone}) async {
    final docRef = _groupProgressCollection.doc(inviteId);
    await docRef.update({
      'unlockedMilestones': FieldValue.arrayUnion([milestone])
    });
  }
  @override
  Stream<List<GroupChallengeProgressModel>> watchGroupProgressByContextId(String contextId) {
    return _groupProgressCollection
        .where('contextId',
        isEqualTo: contextId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs
          .map((doc) => GroupChallengeProgressModel.fromSnapshot(doc))
          .toList();
    });
  }
}