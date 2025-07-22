import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invite_model.dart';

abstract class InvitesRemoteDataSource {
  Future<void> createInvite(InviteModel invite);
  Future<void> updateRecipientStatus({required String inviteId, required String recipientId, required String newStatus});
  Stream<List<InviteModel>> getInvitesForContext(String contextId);
  Future<InviteModel?> updateAndGetInvite({required String inviteId, required String recipientId, required String newStatus});

}

class InvitesRemoteDataSourceImpl implements InvitesRemoteDataSource {
  final FirebaseFirestore _firestore;

  InvitesRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

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

      final data = snapshot.data() as Map<String, dynamic>;
      (data['recipients'] as Map<String, dynamic>)[recipientId] = newStatus;

      return InviteModel.fromMap(data, snapshot.id);
    });
  }
}