import '../../../challenges/domain/usecases/remove_challenge_from_ongoing_usecase.dart';
import 'package:equatable/equatable.dart';
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/domain/usecases/accept_challenge_usecase.dart';
import '../../../challenges/domain/usecases/add_participant_to_group_challenge_usecase.dart';
import '../../../challenges/domain/usecases/create_group_challenge_progress_usecase.dart';
import '../../../challenges/domain/usecases/start_challenge_usecase.dart';
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

/// {@template accept_challenge_invite_usecase}
/// Use case for accepting a challenge invite.
///
/// This use case handles the logic for a user accepting a challenge invitation.
/// It involves starting the challenge for the user, updating the invite status,
/// and potentially creating or updating a group challenge progress if enough
/// participants have accepted.
/// {@endtemplate}
class AcceptChallengeInviteUseCase {
  /// The repository for managing invites.
  final InvitesRepository _invitesRepository;

  /// Use case for starting a challenge for a user.
  final StartChallengeUseCase _startChallengeUseCase;

  /// Use case for marking a challenge as accepted by a user.
  final AcceptChallengeUseCase _acceptChallengeUseCase;

  /// Use case for creating a progress document for a group challenge.
  final CreateGroupChallengeProgressUseCase _createGroupProgressUseCase;

  /// Use case for adding a participant to an existing group challenge.
  final AddParticipantToGroupChallengeUseCase _addParticipantToGroupChallengeUseCase;

  /// {@macro accept_challenge_invite_usecase}
  AcceptChallengeInviteUseCase(
    this._invitesRepository,
    this._startChallengeUseCase,
    this._acceptChallengeUseCase,
    this._createGroupProgressUseCase,
    this._addParticipantToGroupChallengeUseCase,
  );

  /// Executes the use case to accept a challenge invite.
  ///
  /// [params] The parameters required to accept the invite.
  Future<void> call(AcceptInviteParams params) async {
    // 1. Start the challenge for the accepting user.
    await _acceptChallengeUseCase(UserTaskParams(userId: params.userId, challengeId: params.challenge.id));
    await _startChallengeUseCase(StartChallengeParams(
      userId: params.userId,
      challenge: params.challenge,
      inviteId: params.invite.id,
    ));

    // 2. Update the status in the invitation and get the updated invitation back.
    final updatedInvite = await _invitesRepository.updateAndGetInvite(
      inviteId: params.invite.id,
      recipientId: params.userId,
      newStatus: InviteStatus.accepted,
    );

    if (updatedInvite == null) return; // Invitation not found, abort process.

    // 3. Count how many people have accepted.
    final acceptedUserIds = updatedInvite.recipients.entries
        .where((entry) => entry.value == InviteStatus.accepted)
        .map((entry) => entry.key)
        .toList();

    final contextId = updatedInvite.contextId;
    if (contextId == null) return;

    // 4. Check the condition for group challenge creation or update.
    if (acceptedUserIds.length == CreateGroupChallengeProgressUseCase.minParticipantsForGroupChallenge) {
      // If the minimum number of participants is reached, create the group challenge progress.
      await _createGroupProgressUseCase(
        inviteId: updatedInvite.id,
        contextId: contextId,
        challenge: params.challenge,
        initialParticipantIds: acceptedUserIds,
      );
    } else if (acceptedUserIds.length > CreateGroupChallengeProgressUseCase.minParticipantsForGroupChallenge) {
      // If more than the minimum number of participants have accepted,
      // add the user to the existing progress document.
      await _addParticipantToGroupChallengeUseCase(AddParticipantParams(
        inviteId: updatedInvite.id,
        userId: params.userId,
        tasksPerUser: params.challenge.tasks.length,
      ));
    }
  }
}

/// {@template accept_invite_params}
/// Parameters required for the [AcceptChallengeInviteUseCase].
/// {@endtemplate}
class AcceptInviteParams extends Equatable {
  /// The invitation entity being accepted.
  final InviteEntity invite;

  /// The ID of the user accepting the invite.
  final String userId;

  /// The challenge entity associated with the invite.
  final ChallengeEntity challenge;

  /// {@macro accept_invite_params}
  const AcceptInviteParams({required this.invite, required this.userId, required this.challenge});

  @override
  List<Object?> get props => [invite, userId, challenge];
}
