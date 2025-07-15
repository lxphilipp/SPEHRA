import 'package:equatable/equatable.dart';
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

class DeclineChallengeInviteUseCase {
  final InvitesRepository _repository;

  DeclineChallengeInviteUseCase(this._repository);

  Future<void> call(DeclineInviteParams params) async {
    return _repository.updateRecipientStatus(
      inviteId: params.inviteId,
      recipientId: params.userId,
      newStatus: InviteStatus.declined,
    );
  }
}

class DeclineInviteParams extends Equatable {
  final String inviteId;
  final String userId;

  const DeclineInviteParams({required this.inviteId, required this.userId});

  @override
  List<Object?> get props => [inviteId, userId];
}