import 'package:rxdart/rxdart.dart';
import '../../../challenges/domain/entities/group_challenge_progress_entity.dart';
import '../../../challenges/domain/repositories/challenge_progress_repository.dart';
import '../../../invites/domain/entities/invite_entity.dart';
import '../../../invites/domain/usecases/get_invites_for_context_usecase.dart';
import '../entities/message_entity.dart';
import 'get_group_messages_stream_usecase.dart';

/// A use case that combines messages, invites, and group challenge progress
/// into a single stream of chat items, sorted by their creation date.
class GetCombinedChatItemsUseCase {
  final GetGroupMessagesStreamUseCase _getMessagesStreamUseCase;
  final GetInvitesForContextUseCase _getInvitesForContextUseCase;
  final ChallengeProgressRepository _progressRepository;

  /// Creates a [GetCombinedChatItemsUseCase].
  ///
  /// [_getMessagesStreamUseCase] is used to fetch the stream of messages.
  /// [_getInvitesForContextUseCase] is used to fetch the stream of invites.
  /// [_progressRepository] is used to fetch the stream of group challenge progress.
  GetCombinedChatItemsUseCase(
      this._getMessagesStreamUseCase,
      this._getInvitesForContextUseCase,
      this._progressRepository,
      );

  /// Combines and returns a stream of chat items (messages, invites, and
  /// group challenge progress) for a given [groupId].
  ///
  /// The items are sorted in descending order based on their creation date.
  /// If an item does not have a creation date (e.g., a [MessageEntity] with a
  /// null `createdAt`), it defaults to a very early date (1970) for sorting
  /// purposes, effectively placing it at the end of the sorted list if other
  /// items have valid dates.
  ///
  /// [groupId] is the ID of the group for which to fetch the combined chat items.
  ///
  /// Returns a [Stream] of [List] of dynamic items, where each item can be
  /// a [MessageEntity], [InviteEntity], or [GroupChallengeProgressEntity].
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
