import 'dart:io';
import '../entities/chat_room_entity.dart';
import '../entities/group_chat_entity.dart';
import '../entities/message_entity.dart';
import '../entities/chat_user_entity.dart';

abstract class ChatRepository {
  // --- Chat Room Operations ---
  Future<String?> createOrGetChatRoom(String currentUserId, String partnerUserId, {MessageEntity? initialMessage});
  Stream<List<ChatRoomEntity>> getChatRoomsStream(String currentUserId);
  Future<void> updateChatRoomWithMessage({
    required String roomId,
    required String lastMessage,
    required String messageType,
  });
  Future<void> hideChatForUser(String roomId, String userId);
  Future<void> unhideChatForUser(String roomId, String userId);
  Future<void> setChatClearedTimestamp(String roomId, String userId);
  Stream<ChatRoomEntity?> watchChatRoomById(String roomId);

  // --- Group Chat Operations ---
  Future<String?> createGroupChat({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    required String currentUserId,
    String? imageUrl,
    MessageEntity? initialMessage,
  });
  Stream<List<GroupChatEntity>> getGroupChatsStream(String currentUserId);
  Future<void> updateGroupChatWithMessage({
    required String groupId,
    required String lastMessage,
    required String messageType,
  });
  Future<void> updateGroupChatDetails(GroupChatEntity groupChatEntity);
  Future<void> addMembersToGroup(String groupId, List<String> memberIdsToAdd);
  Future<void> removeMemberFromGroup(String groupId, String memberIdToRemove);
  Stream<GroupChatEntity?> watchGroupChatById({required String groupId});
  Future<void> deleteGroup(String groupId);

  // --- Message Operations ---
  Future<void> sendMessage({
    required MessageEntity message,
    required String contextId,
    required bool isGroupMessage,
  });
  Stream<List<MessageEntity>> getMessagesStream(String roomId);
  Stream<List<MessageEntity>> getGroupMessagesStream(String groupId);
  Future<void> markMessageAsRead({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
    required String readerUserId,
  });
  Future<void> deleteMessage({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
  });

  // --- User Related Operations for Chat ---
  Future<ChatUserEntity?> getChatUserById(String userId);
  Stream<List<ChatUserEntity>> getChatUsersStreamByIds(List<String> userIds);
  Future<List<ChatUserEntity>> findChatUsersByNamePrefix(String namePrefix, {List<String> excludeIds = const []});

  // --- Storage Operations ---
  Future<String?> uploadChatImage({
    required File imageFile,
    required String contextId,
    required String uploaderUserId,
  });

}