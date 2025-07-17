import '../../domain/entities/invite_entity.dart';
import '../../domain/repositories/invites_repository.dart';
import '../datasources/invites_remote_datasource.dart';
import '../models/invite_model.dart';

class InvitesRepositoryImpl implements InvitesRepository {
  final InvitesRemoteDataSource remoteDataSource;

  InvitesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createInvite(InviteEntity invite) {
    final model = InviteModel.fromEntity(invite);
    return remoteDataSource.createInvite(model);
  }

  @override
  Future<void> updateRecipientStatus({
    required String inviteId,
    required String recipientId,
    required InviteStatus newStatus,
  }) {
    return remoteDataSource.updateRecipientStatus(
      inviteId: inviteId,
      recipientId: recipientId,
      newStatus: newStatus.name, // Wandle Enum in String um
    );
  }

  @override
  Stream<List<InviteEntity>> getInvitesForContext(String contextId) {
    return remoteDataSource.getInvitesForContext(contextId).map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }
  @override
  Future<InviteEntity?> updateAndGetInvite({required String inviteId, required String recipientId, required InviteStatus newStatus}) async {
    final model = await remoteDataSource.updateAndGetInvite(
      inviteId: inviteId,
      recipientId: recipientId,
      newStatus: newStatus.name, // Enum in String umwandeln
    );
    return model?.toEntity(); // Model in Entity umwandeln
  }
}