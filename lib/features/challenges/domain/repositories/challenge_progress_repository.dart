import '../entities/challenge_progress_entity.dart';
import '../entities/group_challenge_progress_entity.dart';
import '../entities/task_progress_entity.dart';

/// Abstract class for managing challenge progress.
///
/// This repository provides methods for watching, creating, and updating
/// individual and group challenge progress, as well as managing participant
/// involvement and milestone tracking.
abstract class ChallengeProgressRepository {
  /// Watches the progress of a specific challenge.
  ///
  /// Returns a stream of [ChallengeProgressEntity] that emits updates
  /// whenever the challenge progress changes.
  ///
  /// - [progressId]: The ID of the challenge progress to watch.
  Stream<ChallengeProgressEntity?> watchChallengeProgress(String progressId);

  /// Creates a new challenge progress entry.
  ///
  /// - [progress]: The [ChallengeProgressEntity] to create.
  Future<void> createChallengeProgress(ChallengeProgressEntity progress);

  /// Updates the state of a specific task within a challenge progress.
  ///
  /// - [progressId]: The ID of the challenge progress.
  /// - [taskId]: The ID of the task to update.
  /// - [newState]: The new [TaskProgressEntity] representing the updated state.
  Future<void> updateTaskState(String progressId, String taskId, TaskProgressEntity newState);

  /// Creates a new group challenge progress entry.
  ///
  /// - [groupProgress]: The [GroupChallengeProgressEntity] to create.
  Future<void> createGroupProgress(GroupChallengeProgressEntity groupProgress);

  /// Retrieves the progress of a group challenge using an invite ID.
  ///
  /// Returns a [GroupChallengeProgressEntity] if found, otherwise null.
  ///
  /// - [inviteId]: The invite ID associated with the group challenge.
  Future<GroupChallengeProgressEntity?> getGroupProgress(String inviteId);

  /// Adds a participant to a group challenge progress.
  ///
  /// - [inviteId]: The invite ID of the group challenge.
  /// - [userId]: The ID of the user to add as a participant.
  /// - [tasksPerUser]: The number of tasks assigned to this user.
  Future<void> addParticipantToGroupProgress({required String inviteId, required String userId, required int tasksPerUser});

  /// Increments the progress of a group challenge.
  ///
  /// Returns the updated [GroupChallengeProgressEntity] if successful, otherwise null.
  ///
  /// - [inviteId]: The invite ID of the group challenge to increment.
  Future<GroupChallengeProgressEntity?> incrementGroupProgress(String inviteId);

  /// Marks a milestone within a group challenge as awarded.
  ///
  /// - [inviteId]: The invite ID of the group challenge.
  /// - [milestone]: The milestone number to mark as awarded.
  Future<void> markMilestoneAsAwarded(String inviteId, int milestone);

  /// Watches for group challenge progress entries associated with a specific context ID.
  ///
  /// Returns a stream of a list of [GroupChallengeProgressEntity] that emits
  /// updates whenever relevant group challenge progress changes.
  ///
  /// - [contextId]: The context ID (e.g., team ID, organization ID) to filter by.
  Stream<List<GroupChallengeProgressEntity>> watchGroupProgressByContextId(String contextId);
}