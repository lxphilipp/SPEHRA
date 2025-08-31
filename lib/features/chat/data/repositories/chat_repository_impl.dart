import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/group_chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart'; // Das Interface
import '../models/chat_room_model.dart';
import '../models/group_chat_model.dart';
import '../models/message_model.dart';

/// Implementation of the [ChatRepository] interface.
///
/// This class handles the communication with the [ChatRemoteDataSource]
/// and maps the data models to domain entities.
class ChatRepositoryImpl implements ChatRepository {
  /// The remote data source for chat operations.
  final ChatRemoteDataSource remoteDataSource;

  /// Creates a [ChatRepositoryImpl].
  ///
  /// Requires a [remoteDataSource] to interact with the backend.
  ChatRepositoryImpl({required this.remoteDataSource});

  // --- Mapping Hilfsmethoden (Model zu Entity) ---

  /// Maps a [ChatRoomModel] to a [ChatRoomEntity].
  ChatRoomEntity _mapChatRoomModelToEntity(ChatRoomModel model) {
    final clearedAtMap = <String, DateTime>{};
    model.clearedAt.forEach((key, value) {
      if (value is Timestamp) {
        clearedAtMap[key] = value.toDate();
      }
    });

    return ChatRoomEntity(
      id: model.id,
      members: model.members,
      lastMessage: model.lastMessage,
      lastMessageTime: model.lastMessageTime,
      createdAt: model.createdAt,
      hiddenFor: model.hiddenFor,
      clearedAt: clearedAtMap,
    );
  }

  /// Maps a [GroupChatModel] to a [GroupChatEntity].
  GroupChatEntity _mapGroupChatModelToEntity(GroupChatModel model) {
    return GroupChatEntity(
      id: model.id,
      name: model.name,
      imageUrl: model.imageUrl,
      adminIds: model.adminIds,
      memberIds: model.memberIds,
      lastMessage: model.lastMessage,
      lastMessageTime: model.lastMessageTime,
      createdAt: model.createdAt,
    );
  }

  /// Maps a [MessageModel] to a [MessageEntity].
  MessageEntity _mapMessageModelToEntity(MessageModel model) {
    return MessageEntity(
      id: model.id,
      toId: model.toId,
      fromId: model.fromId,
      msg: model.msg,
      type: model.type,
      createdAt: model.createdAt,
      readAt: model.readAt,
    );
  }

  /// Maps a [MessageEntity] to a [MessageModel].
  MessageModel _mapMessageEntityToModel(MessageEntity entity) {
    return MessageModel(
      id: entity.id, // ID kann hier leer sein, wenn sie von der DS generiert wird
      toId: entity.toId,
      fromId: entity.fromId,
      msg: entity.msg,
      type: entity.type,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }

  /// Maps a [GroupChatEntity] to a [GroupChatModel].
  GroupChatModel _mapGroupChatEntityToModel(GroupChatEntity entity) {
    return GroupChatModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      adminIds: entity.adminIds,
      memberIds: entity.memberIds,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      createdAt: entity.createdAt,
    );
  }


  // --- Implementierung der Repository-Methoden ---

  @override
  Future<String?> createOrGetChatRoom(String currentUserId, String partnerUserId, {MessageEntity? initialMessage}) async {
    try {
      // Hier müssen wir currentUserId explizit übergeben, da die DataSource es braucht.
      return await remoteDataSource.createOrGetChatRoom(
        currentUserId: currentUserId, // Explizit übergeben
        partnerUserId: partnerUserId,
        initialMessage: initialMessage != null ? _mapMessageEntityToModel(initialMessage) : null,
      );
    } on ChatDataSourceException catch (e) {
      AppLogger.error("Error in createOrGetChatRoom", e);
      return null;
    } catch (e) {
      AppLogger.error("Unexpected error in createOrGetChatRoom", e);
      return null;
    }
  }

  @override
  Stream<List<ChatRoomEntity>> getChatRoomsStream(String currentUserId) {
    try {
      return remoteDataSource.getChatRoomsStream(currentUserId)
          .map((models) => models.map(_mapChatRoomModelToEntity).toList())
          .handleError((error) {
        AppLogger.error("Error in getChatRoomsStream", error);
        // Fehler im Stream weitergeben
        if (error is ChatDataSourceException) throw error;
        throw Exception("Unknown error in chat room stream: $error");
      });
    } catch (e) {
      AppLogger.error("Unexpected error creating chat room stream", e);
      return Stream.error(Exception("Error creating chat room stream: $e"));
    }
  }

  @override
  Future<void> updateChatRoomWithMessage({ required String roomId, required String lastMessage, required String messageType}) async {
    try {
      await remoteDataSource.updateChatRoomWithMessage(roomId: roomId, lastMessage: lastMessage, messageType: messageType);
    } catch (e) {
      AppLogger.error("Error in updateChatRoomWithMessage", e);
      rethrow;
    }
  }

  @override
  Future<String?> createGroupChat({ required String name, required List<String> memberIds, required List<String> adminIds,required String currentUserId, String? imageUrl, MessageEntity? initialMessage}) async {
    try {
      return await remoteDataSource.createGroupChat(
        name: name,
        memberIds: memberIds,
        adminIds: adminIds,
        currentUserId: currentUserId,
        imageUrl: imageUrl,
        initialMessage: initialMessage != null ? _mapMessageEntityToModel(initialMessage) : null,
      );
    } catch (e) {
      AppLogger.error("Error in createGroupChat", e);
      return null;
    }
  }

  @override
  Stream<List<GroupChatEntity>> getGroupChatsStream(String currentUserId) {
    try {
      return remoteDataSource.getGroupChatsStream(currentUserId)
          .map((models) => models.map(_mapGroupChatModelToEntity).toList())
          .handleError((error) {
        AppLogger.error("ChatRepo Error in stream: $error");
        if (error is ChatDataSourceException) throw error;
        throw Exception("Unknown error in group chat stream: $error");
      });
    } catch (e) {
      AppLogger.error("ChatRepo Error: Unexpected error creating group chat stream: $e");
      return Stream.error(Exception("Error creating group chat stream: $e"));
    }
  }

  @override
  Future<void> updateGroupChatWithMessage({ required String groupId, required String lastMessage, required String messageType}) async {
    try {
      await remoteDataSource.updateGroupChatWithMessage(groupId: groupId, lastMessage: lastMessage, messageType: messageType);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateGroupChatDetails(GroupChatEntity groupChatEntity) async {
    try {
      await remoteDataSource.updateGroupChatDetails(_mapGroupChatEntityToModel(groupChatEntity));
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> addMembersToGroup(String groupId, List<String> memberIdsToAdd) async {
    try {
      await remoteDataSource.addMembersToGroup(groupId, memberIdsToAdd);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> removeMemberFromGroup(String groupId, String memberIdToRemove) async {
    try {
      await remoteDataSource.removeMemberFromGroup(groupId, memberIdToRemove);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> sendMessage({ required MessageEntity message, required String contextId, required bool isGroupMessage}) async {
    try {
      await remoteDataSource.sendMessage(
        message: _mapMessageEntityToModel(message),
        contextId: contextId,
        isGroupMessage: isGroupMessage,
      );
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(String roomId) {
    try {
      return remoteDataSource.getMessagesStream(roomId)
          .map((models) => models.map(_mapMessageModelToEntity).toList())
          .handleError((error) {
        AppLogger.error("ChatRepo Error in stream: $error");
        if (error is ChatDataSourceException) throw error;
        throw Exception("Unknown error in message stream: $error");
      });
    } catch (e) {
      AppLogger.error("ChatRepo Error: Unexpected error creating message stream: $e");
      return Stream.error(Exception("Error creating message stream: $e"));
    }
  }

  @override
  Stream<List<MessageEntity>> getGroupMessagesStream(String groupId) {
    try {
      return remoteDataSource.getGroupMessagesStream(groupId)
          .map((models) => models.map(_mapMessageModelToEntity).toList())
          .handleError((error) {
        AppLogger.error("ChatRepo Error in stream: $error");
        if (error is ChatDataSourceException) throw error;
        throw Exception("Unknown error in group message stream: $error");
      });
    } catch (e) {
      AppLogger.error("ChatRepo Error: Unexpected error creating group message stream: $e");
      return Stream.error(Exception("Error creating group message stream: $e"));
    }
  }

  @override
  Future<void> markMessageAsRead({ required String contextId, required String messageId, required bool isGroupMessage, required String readerUserId}) async {
    try {
      await remoteDataSource.markMessageAsRead(contextId: contextId, messageId: messageId, isGroupMessage: isGroupMessage, readerUserId: readerUserId);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage({ required String contextId, required String messageId, required bool isGroupMessage}) async {
    try {
      await remoteDataSource.deleteMessage(contextId: contextId, messageId: messageId, isGroupMessage: isGroupMessage);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      rethrow;
    }
  }

  @override
  Future<ChatUserEntity?> getChatUserById(String userId) async {
    try {
      return await remoteDataSource.getChatUserById(userId);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      return null;
    }
  }

  @override
  Stream<List<ChatUserEntity>> getChatUsersStreamByIds(List<String> userIds) {
    try {
      return remoteDataSource.getChatUsersStreamByIds(userIds)
          .handleError((error) {
        AppLogger.error("ChatRepo Error in stream: $error");
        if (error is ChatDataSourceException) throw error;
        throw Exception("Unknown error in chat user stream: $error");
      });
    } catch (e) {
      AppLogger.error("ChatRepo Error: Unexpected error creating chat user stream: $e");
      return Stream.error(Exception("Error creating chat user stream: $e"));
    }
  }

  @override
  Future<List<ChatUserEntity>> findChatUsersByNamePrefix(String namePrefix, {List<String> excludeIds = const []}) async {
    try {
      // Pass the excludeIds to the remoteDataSource
      return await remoteDataSource.findChatUsersByNamePrefix(namePrefix, excludeIds: excludeIds);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      return []; // Leere Liste bei Fehler
    }
  }

  @override
  Future<String?> uploadChatImage({ required File imageFile, required String contextId, required String uploaderUserId}) async {
    try {
      return await remoteDataSource.uploadChatImage(imageFile: imageFile, contextId: contextId, uploaderUserId: uploaderUserId);
    } catch (e) {
      AppLogger.error("ChatRepo Error: $e");
      return null;
    }
  }
  @override
  Stream<GroupChatEntity?> watchGroupChatById({required String groupId}) {
    try {
      return remoteDataSource.watchGroupChatById(groupId).map((model) {
        return model != null ? _mapGroupChatModelToEntity(model) : null;
      }).handleError((error) {
        AppLogger.error("ChatRepo: Fehler im watchGroupChatById Stream für $groupId", error);
        if (error is ChatDataSourceException) throw error;
        throw Exception("Unbekannter Fehler im Stream der Gruppendetails: $error");
      });
    } catch (e) {
      AppLogger.error("ChatRepo: Fehler beim Erstellen des watchGroupChatById Streams für $groupId", e);
      return Stream.error(Exception("Fehler beim Erstellen des Streams für Gruppendetails: $e"));
    }
  }
  @override
  Future<void> deleteGroup(String groupId) async {
    // try-catch block could be added here for error handling if needed
    await remoteDataSource.deleteGroup(groupId);
  }

  @override
  Future<void> hideChatForUser(String roomId, String userId) async {
    // try-catch block could be added here for error handling if needed
    await remoteDataSource.hideChatForUser(roomId, userId);
  }

  @override
  Future<void> unhideChatForUser(String roomId, String userId) async {
    // try-catch block could be added here for error handling if needed
    await remoteDataSource.unhideChatForUser(roomId, userId);
  }

  @override
  Future<void> setChatClearedTimestamp(String roomId, String userId) async {
    // try-catch block could be added here for error handling if needed
    await remoteDataSource.setChatClearedTimestamp(roomId, userId);
  }

  @override
  Stream<ChatRoomEntity?> watchChatRoomById(String roomId) {
    // try-catch block could be added here for error handling if needed
    return remoteDataSource
        .watchChatRoomById(roomId)
        .map((model) => model != null ? _mapChatRoomModelToEntity(model) : null);
  }
}
