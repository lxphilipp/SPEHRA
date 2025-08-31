import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invite_model.dart';

/// Abstract class for remote data operations related to invites.
abstract class InvitesRemoteDataSource {
  /// Creates a new invite.
  ///
  /// Takes an [InviteModel] and persists it.
  Future<void> createInvite(InviteModel invite);

  /// Updates the status of a recipient for a specific invite.
  ///
  /// Requires [inviteId], [recipientId], and the [newStatus].
  Future<void> updateRecipientStatus({required String inviteId, required String recipientId, required String newStatus});

  /// Retrieves a stream of invites for a given context.
  ///
  /// Filters invites by [contextId] and orders them by creation date.
  Stream<List<InviteModel>> getInvitesForContext(String contextId);

  /// Updates the status of a recipient and returns the updated invite.
  ///
  /// Atomically updates the recipient's status and fetches the modified invite.
  /// Returns `null` if the invite does not exist.
  Future<InviteModel?> updateAndGetInvite({required String inviteId, required String recipientId, required String newStatus});

}

/// Implementation of [InvitesRemoteDataSource] using Firebase Firestore.
class InvitesRemoteDataSourceImpl implements InvitesRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Creates an instance of [InvitesRemoteDataSourceImpl].
  ///
  /// Requires a [FirebaseFirestore] instance.
  InvitesRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Provides a [CollectionReference] to the 'invites' collection in Firestore.
  CollectionReference get _invitesCollection => _firestore.collection('invites');

  @override
  Future<void> createInvite(InviteModel invite) async {
    await _invitesCollection.doc(invite.id).set(invite.toMap());
  }

  @override
  Future<void> updateRecipientStatus({required String inviteId, required String recipientId, required String newStatus}) async {
    await _invitesCollection.doc(inviteId).update({
      'recipients.$recipientId': newStatus,
    });
  }

  @override
  Stream<List<InviteModel>> getInvitesForContext(String contextId) {
    return _invitesCollection
        .where('contextId', isEqualTo: contextId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => InviteModel.fromSnapshot(doc)).toList();
    });
  }
  @override
  Future<InviteModel?> updateAndGetInvite({required String inviteId, required String recipientId, required String newStatus}) async {
    final docRef = _invitesCollection.doc(inviteId);

    return _firestore.runTransaction<InviteModel?>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        return null;
      }

      transaction.update(docRef, {'recipients.$recipientId': newStatus});

      // Manually update the local data copy before returning,
      // as the transaction.get(docRef) inside the transaction
      // would not reflect the update immediately.
      final data = snapshot.data() as Map<String, dynamic>;
      // Ensure recipients map exists, though in a valid state it always should if the document exists.
      data['recipients'] = (data['recipients'] as Map<String, dynamic>? ?? {})..addAll({recipientId: newStatus});


      return InviteModel.fromMap(data, snapshot.id);
    });
  }
}