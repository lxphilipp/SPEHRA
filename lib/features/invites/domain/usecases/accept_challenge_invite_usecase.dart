import '../../../challenges/domain/usecases/remove_challenge_from_ongoing_usecase.dart';
import 'package:equatable/equatable.dart';
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/domain/usecases/accept_challenge_usecase.dart';
import '../../../challenges/domain/usecases/add_participant_to_group_challenge_usecase.dart';
import '../../../challenges/domain/usecases/create_group_challenge_progress_usecase.dart';
import '../../../challenges/domain/usecases/start_challenge_usecase.dart';
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

class AcceptChallengeInviteUseCase {
  final InvitesRepository _invitesRepository;
  final StartChallengeUseCase _startChallengeUseCase;
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final CreateGroupChallengeProgressUseCase _createGroupProgressUseCase;
  final AddParticipantToGroupChallengeUseCase _addParticipantToGroupChallengeUseCase;

  AcceptChallengeInviteUseCase(
    this._invitesRepository,
    this._startChallengeUseCase,
    this._acceptChallengeUseCase,
    this._createGroupProgressUseCase,
    this._addParticipantToGroupChallengeUseCase,
  );

  Future<void> call(AcceptInviteParams params) async {
    // 1. Starte die Challenge für den annehmenden User
    await _acceptChallengeUseCase(UserTaskParams(userId: params.userId, challengeId: params.challenge.id));
    await _startChallengeUseCase(StartChallengeParams(
      userId: params.userId,
      challenge: params.challenge,
      inviteId: params.invite.id,
    ));

    // 2. Aktualisiere den Status in der Einladung und erhalte die aktualisierte Einladung zurück
    final updatedInvite = await _invitesRepository.updateAndGetInvite(
      inviteId: params.invite.id,
      recipientId: params.userId,
      newStatus: InviteStatus.accepted,
    );

    if (updatedInvite == null) return; // Einladung nicht gefunden, Prozess abbrechen

    // 3. Zähle, wie viele Leute zugesagt haben
    final acceptedUserIds = updatedInvite.recipients.entries
        .where((entry) => entry.value == InviteStatus.accepted)
        .map((entry) => entry.key)
        .toList();

    final contextId = updatedInvite.contextId;
    if (contextId == null) return;

    // 4. Prüfe die Bedingung
    if (acceptedUserIds.length == CreateGroupChallengeProgressUseCase.minParticipantsForGroupChallenge) {
      await _createGroupProgressUseCase(
        inviteId: updatedInvite.id,
        contextId: contextId,
        challenge: params.challenge,
        initialParticipantIds: acceptedUserIds,
      );
    } else if (acceptedUserIds.length > CreateGroupChallengeProgressUseCase.minParticipantsForGroupChallenge) {
      // Füge den User dem bestehenden Fortschrittsdokument hinzu.
      await _addParticipantToGroupChallengeUseCase(AddParticipantParams(
        inviteId: updatedInvite.id,
        userId: params.userId,
        tasksPerUser: params.challenge.tasks.length,
      ));
    }
  }
}

class AcceptInviteParams extends Equatable {
  final InviteEntity invite;
  final String userId;
  final ChallengeEntity challenge;

  const AcceptInviteParams({required this.invite, required this.userId, required this.challenge});

  @override
  List<Object?> get props => [invite, userId, challenge];
}