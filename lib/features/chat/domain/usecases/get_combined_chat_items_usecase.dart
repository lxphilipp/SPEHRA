import 'package:rxdart/rxdart.dart';
import '../../../invites/domain/entities/invite_entity.dart';
import '../../../invites/domain/usecases/get_invites_for_context_usecase.dart';
import '../entities/message_entity.dart';
import 'get_group_messages_stream_usecase.dart';

class GetCombinedChatItemsUseCase {
  final GetGroupMessagesStreamUseCase _getMessagesStreamUseCase;
  final GetInvitesForContextUseCase _getInvitesForContextUseCase;

  GetCombinedChatItemsUseCase(this._getMessagesStreamUseCase, this._getInvitesForContextUseCase);

  Stream<List<dynamic>> call(String groupId) {
    final messagesStream = _getMessagesStreamUseCase(groupId: groupId);
    final invitesStream = _getInvitesForContextUseCase(groupId);

    return Rx.combineLatest2(
      messagesStream,
      invitesStream,
          (List<MessageEntity> messages, List<InviteEntity> invites) {
        final List<dynamic> combinedList = [...messages, ...invites];
        combinedList.sort((a, b) {
          final aDate = (a is MessageEntity) ? a.createdAt ?? DateTime(1970) : (a as InviteEntity).createdAt;
          final bDate = (b is MessageEntity) ? b.createdAt ?? DateTime(1970) : (b as InviteEntity).createdAt;
          return bDate.compareTo(aDate);
        });
        return combinedList;
      },
    );
  }
}