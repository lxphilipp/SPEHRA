import 'package:equatable/equatable.dart';
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/domain/usecases/start_challenge_usecase.dart';
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

class AcceptChallengeInviteUseCase {
  final InvitesRepository _invitesRepository;
  final StartChallengeUseCase _startChallengeUseCase;

  AcceptChallengeInviteUseCase(this._invitesRepository, this._startChallengeUseCase);

  Future<void> call(AcceptInviteParams params) async {
    await _invitesRepository.updateRecipientStatus(
      inviteId: params.inviteId,
      recipientId: params.userId,
      newStatus: InviteStatus.accepted,
    );

    await _startChallengeUseCase(StartChallengeParams(
      userId: params.userId,
      challenge: params.challenge,
    ));
  }
}

class AcceptInviteParams extends Equatable {
  final String inviteId;
  final String userId;
  final ChallengeEntity challenge;

  const AcceptInviteParams({
    required this.inviteId,
    required this.userId,
    required this.challenge,
  });

  @override
  List<Object?> get props => [inviteId, userId, challenge];
}