import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../challenges/domain/usecases/accept_challenge_usecase.dart'; // <-- NEU
import '../../../challenges/domain/usecases/get_challenge_by_id_usecase.dart';
import '../../../challenges/domain/usecases/remove_challenge_from_ongoing_usecase.dart';
import '../../../challenges/domain/usecases/start_challenge_usecase.dart';
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

class CreateChallengeInviteUseCase {
  final InvitesRepository _invitesRepository;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  final StartChallengeUseCase _startChallengeUseCase;
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final Uuid _uuid;

  CreateChallengeInviteUseCase(
      this._invitesRepository,
      this._getChallengeByIdUseCase,
      this._startChallengeUseCase,
      this._acceptChallengeUseCase,
      this._uuid,
      );

  Future<void> call(CreateInviteParams params) async {
    final challenge = await _getChallengeByIdUseCase(params.challengeId);
    if (challenge == null) {
      throw Exception('Challenge für Einladung nicht gefunden');
    }

    final recipientsMap = {
      for (var id in params.recipientIds)
        id: id == params.inviterId ? InviteStatus.accepted : InviteStatus.pending
    };

    final newInvite = InviteEntity(
      id: _uuid.v4(),
      inviterId: params.inviterId,
      targetId: params.challengeId,
      targetTitle: challenge.title,
      context: params.context,
      contextId: params.contextId,
      recipients: recipientsMap,
      createdAt: DateTime.now(),
    );

    await _invitesRepository.createInvite(newInvite);
    await _acceptChallengeUseCase(UserTaskParams(
      userId: params.inviterId,
      challengeId: challenge.id,
    ));
    await _startChallengeUseCase(StartChallengeParams(
      userId: params.inviterId,
      challenge: challenge,
    ));
  }
}

class CreateInviteParams extends Equatable {
  final String inviterId;
  final String challengeId;
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