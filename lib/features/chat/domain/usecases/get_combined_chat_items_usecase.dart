import 'package:rxdart/rxdart.dart';
import '../../../challenges/domain/entities/group_challenge_progress_entity.dart';
import '../../../challenges/domain/repositories/challenge_progress_repository.dart'; // <-- NEUER IMPORT
import '../../../invites/domain/entities/invite_entity.dart';
import '../../../invites/domain/usecases/get_invites_for_context_usecase.dart';
import '../entities/message_entity.dart';
import 'get_group_messages_stream_usecase.dart';

class GetCombinedChatItemsUseCase {
  final GetGroupMessagesStreamUseCase _getMessagesStreamUseCase;
  final GetInvitesForContextUseCase _getInvitesForContextUseCase;
  final ChallengeProgressRepository _progressRepository;

  GetCombinedChatItemsUseCase(
      this._getMessagesStreamUseCase,
      this._getInvitesForContextUseCase,
      this._progressRepository,
      );

  Stream<List<dynamic>> call(String groupId) {
    final messagesStream = _getMessagesStreamUseCase(groupId: groupId);
    final invitesStream = _getInvitesForContextUseCase(groupId);
    final groupProgressStream = _progressRepository.watchGroupProgressByContextId(groupId);

    final streams = [
      messagesStream,
      invitesStream,
      groupProgressStream,
    ];

    return Rx.combineLatest(streams, (List<List<dynamic>> lists) {
      final List<dynamic> combinedList = lists.expand((list) => list).toList();

      combinedList.sort((a, b) {
        final DateTime aDate;
        final DateTime bDate;

        if (a is MessageEntity) {
          aDate = a.createdAt ?? DateTime(1970);
        } else if (a is InviteEntity) {
          aDate = a.createdAt;
        } else if (a is GroupChallengeProgressEntity) {
          aDate = a.createdAt;
        } else {
          aDate = DateTime(1970);
        }

        if (b is MessageEntity) {
          bDate = b.createdAt ?? DateTime(1970);
        } else if (b is InviteEntity) {
          bDate = b.createdAt;
        } else if (b is GroupChallengeProgressEntity) {
          bDate = b.createdAt;
        } else {
          bDate = DateTime(1970);
        }

        return bDate.compareTo(aDate);
      });

      return combinedList;
    });
  }
}