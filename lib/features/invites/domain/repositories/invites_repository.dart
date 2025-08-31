import '../entities/invite_entity.dart';

/// Abstract interface for managing invites.
///
/// This repository provides methods for creating, updating, and retrieving invites
/// related to different chat contexts.
abstract class InvitesRepository {
  /// Creates a new invite in the database.
  ///
  /// Takes an [InviteEntity] object as input and returns a [Future] that
  /// completes when the operation is finished.
  Future<void> createInvite(InviteEntity invite);

  /// Updates the status of a recipient for a specific invite.
  ///
  /// Requires the [inviteId], the [recipientId] whose status needs to be updated,
  /// and the [newStatus] (e.g., 'pending', 'accepted').
  /// Returns a [Future] that completes when the operation is finished.
  Future<void> updateRecipientStatus({
    required String inviteId,
    required String recipientId,
    required InviteStatus newStatus,
  });

  /// Retrieves a stream of all invites relevant to a specific chat context.
  ///
  /// Takes a [contextId] (e.g., a group chat ID) as input and returns a
  /// [Stream] of [List<InviteEntity>] representing the invites.
  Stream<List<InviteEntity>> getInvitesForContext(String contextId);

  /// Updates the status of an invite for a specific recipient and returns the updated invite.
  ///
  /// This method is typically used when a recipient accepts or declines an invitation.
  /// It updates the recipient's status and then fetches the updated invite details.
  ///
  /// Returns a [Future] that resolves to the updated [InviteEntity] if successful,
  /// or `null` if the invite or recipient is not found or an error occurs.
  Future<InviteEntity?> updateAndGetInvite({required String inviteId, required String recipientId, required InviteStatus newStatus});
}
