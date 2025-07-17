import '../entities/invite_entity.dart';

abstract class InvitesRepository {
  /// Erstellt eine neue Einladung in der Datenbank.
  Future<void> createInvite(InviteEntity invite);

  /// Aktualisiert den Status eines Empfängers (z.B. von 'pending' auf 'accepted').
  Future<void> updateRecipientStatus({
    required String inviteId,
    required String recipientId,
    required InviteStatus newStatus,
  });

  /// Liefert einen Stream aller Einladungen, die für einen bestimmten Chat-Kontext
  /// (z.B. einen Gruppenchat) relevant sind.
  Stream<List<InviteEntity>> getInvitesForContext(String contextId);
  Future<InviteEntity?> updateAndGetInvite({required String inviteId, required String recipientId, required InviteStatus newStatus});
}