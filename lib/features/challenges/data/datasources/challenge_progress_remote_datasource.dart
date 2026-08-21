import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/challenge_progress_model.dart';
import '../models/group_challenge_progress_model.dart';

/// Defines the interface for remote data operations related to challenge progress.
abstract class ChallengeProgressRemoteDataSource {
  /// Watches for changes to a specific challenge progress.
  ///
  /// [progressId] The ID of the challenge progress to watch.
  /// Returns a stream of [ChallengeProgressModel], emitting a new model on updates, or null if not found.
  Stream<ChallengeProgressModel?> watchChallengeProgress(String progressId);

  /// Watches every participation of a user, running and completed.
  ///
  /// [userId] The user whose participations to watch.
  Stream<List<ChallengeProgressModel>> watchUserProgress(String userId);

  /// Creates a new challenge progress entry.
  ///
  /// [progress] The [ChallengeProgressModel] to create.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> createChallengeProgress(ChallengeProgressModel progress);

  /// Stamps [completedAt] on a participation.
  ///
  /// [progressId] The ID of the challenge progress.
  Future<void> markChallengeCompleted(String progressId, Timestamp completedAt);

  /// Deletes a participation (the user abandons the challenge).
  ///
  /// [progressId] The ID of the challenge progress.
  Future<void> deleteChallengeProgress(String progressId);

  /// Updates the state of a specific task within a challenge progress.
  ///
  /// [progressId] The ID of the challenge progress.
  /// [taskIndex] The index of the task to update (as a String).
  /// [newStateMap] A map containing the new state for the task.
  /// Returns a [Future] that completes when the operation is done.
  /// Throws an [Exception] if the update fails.
  Future<void> updateTaskState(String progressId, String taskIndex, Map<String, dynamic> newStateMap);

  /// Creates a new group challenge progress entry.
  ///
  /// [groupProgress] The [GroupChallengeProgressModel] to create.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> createGroupProgress(GroupChallengeProgressModel groupProgress);

  /// Retrieves a specific group challenge progress using its invite ID.
  ///
  /// [inviteId] The invite ID of the group challenge progress.
  /// Returns a [Future] resolving to the [GroupChallengeProgressModel], or null if not found.
  Future<GroupChallengeProgressModel?> getGroupProgress(String inviteId);

  /// Adds a participant to an existing group challenge progress.
  ///
  /// [inviteId] The invite ID of the group challenge progress.
  /// [userId] The ID of the user to add.
  /// [tasksPerUser] The number of tasks assigned to this user, used to update total tasks required.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> addParticipantToGroupProgress({required String inviteId, required String userId, required int tasksPerUser});

  /// Increments the completed tasks count for a group challenge progress.
  ///
  /// [inviteId] The invite ID of the group challenge progress.
  /// Returns a [Future] resolving to the updated [GroupChallengeProgressModel],
  /// or null if the document was not found during the transaction.
  Future<GroupChallengeProgressModel?> incrementGroupProgress(String inviteId);

  /// Marks a specific milestone as awarded for a group challenge progress.
  ///
  /// [inviteId] The invite ID of the group challenge progress.
  /// [milestone] The milestone number to mark as awarded.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> markMilestoneAsAwarded({required String inviteId, required int milestone});

  /// Watches for changes to group challenge progress entries associated with a specific context ID.
  ///
  /// [contextId] The context ID (e.g., a challenge ID or an SDG ID) to filter group progress by.
  /// Returns a stream of a list of [GroupChallengeProgressModel].
  Stream<List<GroupChallengeProgressModel>> watchGroupProgressByContextId(String contextId);
}

/// Implementation of [ChallengeProgressRemoteDataSource] using Firebase Firestore.
class ChallengeProgressRemoteDataSourceImpl implements ChallengeProgressRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Creates an instance of [ChallengeProgressRemoteDataSourceImpl].
  ///
  /// [firestore] The [FirebaseFirestore] instance to use for database operations.
  ChallengeProgressRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Reference to the 'challenge_progress' collection in Firestore.
  CollectionReference get _progressCollection => _firestore.collection('challenge_progress');

  /// Reference to the 'group_challenge_progress' collection in Firestore.
  CollectionReference get _groupProgressCollection => _firestore.collection('group_challenge_progress');

  /// Reference to the 'users' collection, needed only for the legacy lists.
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ---------------------------------------------------------------------------
  // LEGACY DUAL-WRITE (migration step 1 of 3)
  //
  // Older app versions derived a user's running/completed challenges from two
  // ID arrays on the user document ('ongoingTasks' / 'completedTasks'). Those
  // arrays are no longer read by this app; the participation documents in
  // 'challenge_progress' are the single source of truth. Until every client
  // is on the new version and the arrays have been dropped (step 3), they are
  // kept in sync here — inside the same WriteBatch as the participation write,
  // so the two can never drift apart.
  // ---------------------------------------------------------------------------

  @override
  Future<void> createChallengeProgress(ChallengeProgressModel progress) async {
    final batch = _firestore.batch();
    batch.set(_progressCollection.doc(progress.id), progress.toMap());
    batch.update(_usersCollection.doc(progress.userId), {
      'ongoingTasks': FieldValue.arrayUnion([progress.challengeId]),
    });
    await batch.commit();
  }

  @override
  Stream<List<ChallengeProgressModel>> watchUserProgress(String userId) {
    return _progressCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((query) => query.docs.map(ChallengeProgressModel.fromSnapshot).toList());
  }

  @override
  Future<void> markChallengeCompleted(String progressId, Timestamp completedAt) async {
    final docRef = _progressCollection.doc(progressId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception("Challenge progress $progressId not found.");
    }
    final data = snapshot.data() as Map<String, dynamic>;
    final userId = data['userId'] as String?;
    final challengeId = data['challengeId'] as String?;

    final batch = _firestore.batch();
    batch.update(docRef, {'completedAt': completedAt});
    if (userId != null && challengeId != null) {
      batch.update(_usersCollection.doc(userId), {
        'ongoingTasks': FieldValue.arrayRemove([challengeId]),
        'completedTasks': FieldValue.arrayUnion([challengeId]),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteChallengeProgress(String progressId) async {
    final docRef = _progressCollection.doc(progressId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;
    final data = snapshot.data() as Map<String, dynamic>;
    final userId = data['userId'] as String?;
    final challengeId = data['challengeId'] as String?;

    final batch = _firestore.batch();
    batch.delete(docRef);
    if (userId != null && challengeId != null) {
      batch.update(_usersCollection.doc(userId), {
        'ongoingTasks': FieldValue.arrayRemove([challengeId]),
      });
    }
    await batch.commit();
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
