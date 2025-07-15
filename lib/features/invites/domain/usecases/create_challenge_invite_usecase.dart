import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../challenges/domain/usecases/get_challenge_by_id_usecase.dart'; // <-- NEUER IMPORT
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

class CreateChallengeInviteUseCase {
  final InvitesRepository _invitesRepository;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase; // <-- NEUE ABHÄNGIGKEIT
  final Uuid _uuid;

  CreateChallengeInviteUseCase(
      this._invitesRepository,
      this._getChallengeByIdUseCase, // <-- NEU IM KONSTRUKTOR
      this._uuid,
      );

  Future<void> call(CreateInviteParams params) async {
    // 1. Hol dir die Challenge-Details über den Use Case
    final challenge = await _getChallengeByIdUseCase(params.challengeId);
    if (challenge == null) {
      throw Exception('Challenge für Einladung nicht gefunden');
    }

    final recipientsMap = {
      for (var id in params.recipientIds) id: InviteStatus.pending
    };

    final newInvite = InviteEntity(
      id: _uuid.v4(),
      inviterId: params.inviterId,
      targetId: params.challengeId,
      targetTitle: challenge.title, // <-- Verwende den Titel aus der geholten Challenge
      context: params.context,
      contextId: params.contextId,
      recipients: recipientsMap,
      createdAt: DateTime.now(),
    );

    return _invitesRepository.createInvite(newInvite);
  }
}

// Die Parameter-Klasse ändert sich leicht: Wir brauchen den Titel nicht mehr.
class CreateInviteParams extends Equatable {
  final String inviterId;
  final String challengeId;
  // final String challengeTitle; <-- WIRD ENTFERNT
  final InviteContext context;
  final String? contextId;
  final List<String> recipientIds;

  const CreateInviteParams({
    required this.inviterId,
    required this.challengeId,
    required this.context,
    this.contextId,
    required this.recipientIds,
  });

  @override
  List<Object?> get props => [inviterId, challengeId, context, contextId, recipientIds];
}