import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

/// Dieser Use Case holt den Live-Stream aller Einladungen für einen
/// bestimmten Kontext (z.B. einen Gruppenchat).
class GetInvitesForContextUseCase {
  final InvitesRepository _repository;

  GetInvitesForContextUseCase(this._repository);

  Stream<List<InviteEntity>> call(String contextId) {
    // Aktuell leitet dieser Use Case die Anfrage nur weiter.
    // In Zukunft könnte hier aber Filter- oder Transformationslogik stehen.
    return _repository.getInvitesForContext(contextId);
  }
}