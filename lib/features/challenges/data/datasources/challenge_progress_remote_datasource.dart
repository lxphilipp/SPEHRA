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

  /// Creates a new challenge progress entry.
  ///
  /// [progress] The [ChallengeProgressModel] to create.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> createChallengeProgress(ChallengeProgressModel progress);

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
