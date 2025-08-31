import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../challenges/domain/usecases/accept_challenge_usecase.dart';
import '../../../challenges/domain/usecases/get_challenge_by_id_usecase.dart';
import '../../../challenges/domain/usecases/remove_challenge_from_ongoing_usecase.dart';
import '../../../challenges/domain/usecases/start_challenge_usecase.dart';
import '../entities/invite_entity.dart';
import '../repositories/invites_repository.dart';

/// {@template create_challenge_invite_usecase}
/// Use case for creating a challenge invite.
///
/// This use case handles the logic for inviting users to a challenge.
/// It creates an invite, accepts the challenge for the inviter, and
/// starts the challenge for the inviter.
/// {@endtemplate}
class CreateChallengeInviteUseCase {
  /// The repository for managing invites.
  final InvitesRepository _invitesRepository;
  /// Use case to get a challenge by its ID.
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  /// Use case to start a challenge for a user.
  final StartChallengeUseCase _startChallengeUseCase;
  /// Use case to accept a challenge for a user.
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  /// A UUID generator.
  final Uuid _uuid;

  /// {@macro create_challenge_invite_usecase}
  CreateChallengeInviteUseCase(
      this._invitesRepository,
      this._getChallengeByIdUseCase,
      this._startChallengeUseCase,
      this._acceptChallengeUseCase,
      this._uuid,
      );

  /// Executes the use case to create a challenge invite.
  ///
  /// [params] The parameters required to create the invite.
  /// Throws an exception if the challenge is not found.
  Future<void> call(CreateInviteParams params) async {
    final challenge = await _getChallengeByIdUseCase(params.challengeId);
    if (challenge == null) {
      throw Exception('No Challenge found for invite');
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

/// {@template create_invite_params}
/// Parameters for creating a new invite.
/// {@endtemplate}
class CreateInviteParams extends Equatable {
  /// The ID of the user creating the invite.
  final String inviterId;
  /// The ID of the challenge to which users are being invited.
  final String challengeId;
  /// The context of the invite (e.g., challenge, group).
  final InviteContext context;
  /// An optional ID related to the context (e.g., group ID if context is group).
  final String? contextId;
  /// A list of user IDs who are recipients of the invite.
  final List<String> recipientIds;

  /// {@macro create_invite_params}
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
