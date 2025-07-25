import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// Chat models and entities
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/message_entity.dart';
import '../models/chat_room_model.dart';
import '../models/group_chat_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/chat_user_entity.dart';

// UserModel from the auth feature for parsing user documents
import '../../../auth/data/models/user_model.dart';


abstract class ChatRemoteDataSource {
  // --- Chat Room Operations (1-on-1 chats) ---

  /// Creates a new chat room between the [currentUserId] and the [partnerUserId]
  /// or returns the ID of an existing room.
  /// [initialMessage] is optional.
  /// Throws a [ChatDataSourceException] on errors.
  Future<String> createOrGetChatRoom({
    required String currentUserId,
    required String partnerUserId,
    MessageModel? initialMessage,
  });

  /// Streams a list of ChatRoomModels that the [currentUserId] is a part of.
  /// The stream emits errors as [ChatDataSourceException].
  Stream<List<ChatRoomModel>> getChatRoomsStream(String currentUserId);

  /// Updates the 'last_message' and 'last_message_time' of a chat room.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> updateChatRoomWithMessage({
    required String roomId,
    required String lastMessage,
    required String messageType,
  });

  Future<void> hideChatForUser(String roomId, String userId);
  Future<void> unhideChatForUser(String roomId, String userId);
  Future<void> setChatClearedTimestamp(String roomId, String userId);
  Stream<ChatRoomModel?> watchChatRoomById(String roomId);

  // --- Group Chat Operations ---

  /// Creates a new chat group.
  /// [currentUserId] is needed for creating the initialMessage.
  /// Throws a [ChatDataSourceException] on errors.
  Future<String> createGroupChat({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    required String currentUserId, // Needed for initialMessage.fromId
    String? imageUrl,
    MessageModel? initialMessage,
  });

  /// Streams a list of GroupChatModels where the [currentUserId] is a member.
  /// The stream emits errors as [ChatDataSourceException].
  Stream<List<GroupChatModel>> getGroupChatsStream(String currentUserId);

  /// Updates the 'last_message' and 'last_message_time' of a group.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> updateGroupChatWithMessage({
    required String groupId,
    required String lastMessage,
    required String messageType,
  });

  /// Updates the general information of a group.
  /// The [groupChatModel] should contain the updated data.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> updateGroupChatDetails(GroupChatModel groupChatModel);

  /// Adds members to an existing group.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> addMembersToGroup(String groupId, List<String> memberIdsToAdd);

  /// Removes a member from a group.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> removeMemberFromGroup(String groupId, String memberIdToRemove);


  // --- Message Operations (for 1-on-1 and groups) ---

  /// Sends a message.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> sendMessage({
    required MessageModel message,
    required String contextId, // roomId or groupId
    required bool isGroupMessage,
  });

  /// Streams messages for a given chat room (1-on-1).
  /// The stream emits errors as [ChatDataSourceException].
  Stream<List<MessageModel>> getMessagesStream(String roomId);

  /// Streams messages for a given group.
  /// The stream emits errors as [ChatDataSourceException].
  Stream<List<MessageModel>> getGroupMessagesStream(String groupId);

  /// Marks a message as read.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> markMessageAsRead({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
    required String readerUserId,
  });

  /// Deletes a message.
  /// Throws a [ChatDataSourceException] on errors.
  Future<void> deleteMessage({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
  });

  // --- User Related Operations for Chat ---

  /// Fetches a single ChatUserEntity by user ID.
  /// Returns null if the user is not found.
  /// Throws a [ChatDataSourceException] on other errors.
  Future<ChatUserEntity?> getChatUserById(String userId);

  /// Streams a list of ChatUserEntities for a list of user IDs.
  /// The stream emits errors as [ChatDataSourceException].
  Stream<List<ChatUserEntity>> getChatUsersStreamByIds(List<String> userIds);

  /// Searches for users whose name starts with the [namePrefix].
  /// Throws a [ChatDataSourceException] on errors.
  Future<List<ChatUserEntity>> findChatUsersByNamePrefix(String namePrefix, {List<String> excludeIds});

  // --- Storage Operations ---

  /// Uploads an image to storage.
  /// Returns the downloadable URL of the image.
  /// Throws a [ChatDataSourceException] on errors.
  Future<String> uploadChatImage({
    required File imageFile,
    required String contextId, // roomId or groupId
    required String uploaderUserId,
  });

  /// Streams a single GroupChatModel by its ID.
  /// Emits null if the group does not exist or is deleted.
  Stream<GroupChatModel?> watchGroupChatById(String groupId);

  Future<void> deleteGroup(String groupId);

}

/// Custom exception for errors in the chat data source.
class ChatDataSourceException implements Exception {
  final String message;
  final dynamic cause; // Optional cause, e.g., the original FirebaseException

  ChatDataSourceException(this.message, {this.cause});

  @override
  String toString() {
    return 'ChatDataSourceException: $message${cause != null ? '\nCause: $cause' : ''}';
  }
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;
  final Uuid uuid;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseStorage,
    required this.uuid,
  });

  // --- Private Hilfsmethoden ---
  ChatUserEntity _mapUserModelToChatUserEntity(UserModel userModel) {
    return ChatUserEntity(
      id: userModel.id!,
      name: userModel.name ?? 'Unknown User',
      imageUrl: userModel.imageURL,
      isOnline: userModel.online,
      lastActiveAt: userModel.lastActiveAt,
    );
  }

  CollectionReference get _usersCollection => firestore.collection('users');
  CollectionReference get _chatRoomsCollection => firestore.collection('rooms');
  CollectionReference get _groupChatsCollection => firestore.collection('groups');

  // --- Chat Room Operations (1-zu-1 Chats) ---

  @override
  Future<String> createOrGetChatRoom({
    required String currentUserId,
    required String partnerUserId,
    MessageModel? initialMessage,
  }) async {
    List<String> memberIds = [currentUserId, partnerUserId]..sort();
    String roomId = memberIds.join('_');

    try {
      final roomDocRef = _chatRoomsCollection.doc(roomId);
      final snapshot = await roomDocRef.get();

      if (!snapshot.exists) {
        final newChatRoom = ChatRoomModel(
          id: roomId,
          members: memberIds,
          createdAt: DateTime.now(),
          lastMessage: initialMessage?.msg,
          lastMessageTime: initialMessage != null ? DateTime.now() : null,
        );
        await roomDocRef.set(newChatRoom.toJsonForCreate());

        if (initialMessage != null) {
          final messageToSend = initialMessage.copyWith(
            id: initialMessage.id.isNotEmpty ? initialMessage.id : uuid.v4(),
            fromId: currentUserId,
            toId: partnerUserId,
            createdAt: DateTime.now(),
          );
          await sendMessage(
            message: messageToSend,
            contextId: roomId,
            isGroupMessage: false,
          );
        }
      } else if (initialMessage != null) {
        final messageToSend = initialMessage.copyWith(
          id: initialMessage.id.isNotEmpty ? initialMessage.id : uuid.v4(),
          fromId: currentUserId,
          toId: partnerUserId,
          createdAt: DateTime.now(),
        );
        await sendMessage(
          message: messageToSend,
          contextId: roomId,
          isGroupMessage: false,
        );
      }
      return roomId;
    } catch (e) {
      throw ChatDataSourceException("Error creating/getting chat room with $partnerUserId", cause: e);
    }
  }

  @override
  Stream<List<ChatRoomModel>> getChatRoomsStream(String currentUserId) {
    try {
      return _chatRoomsCollection
          .where('members', arrayContains: currentUserId)
          .orderBy('last_message_time', descending: true)
          .snapshots(includeMetadataChanges: false)
          .map((querySnapshot) {

        final allChatRooms = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ChatRoomModel.fromJson(data, doc.id);
        }).toList();

        final visibleChatRooms = allChatRooms.where((room) {
          return !room.hiddenFor.contains(currentUserId);
        }).toList();

        return visibleChatRooms;
      });
    } catch (e) {
      AppLogger.error("Error in getChatRoomsStream", e);
      throw ChatDataSourceException("Failed to get chat rooms.", cause: e);
    }
  }

  @override
  Future<void> updateChatRoomWithMessage({
    required String roomId,
    required String lastMessage,
    required String messageType,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'last_message': lastMessage,
        'last_message_time': FieldValue.serverTimestamp(),
      };
      await _chatRoomsCollection.doc(roomId).update(updateData);
    } catch (e) {
      AppLogger.error("Error updating chat room $roomId", e);
      throw ChatDataSourceException("Error updating chat room $roomId", cause: e);
    }
  }

  // --- Group Chat Operations ---
  @override
  Future<String> createGroupChat({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    String? imageUrl,
    MessageModel? initialMessage,
    required String currentUserId,
  }) async {
    final groupId = uuid.v4();
    try {
      final newGroupChat = GroupChatModel(
        id: groupId,
        name: name,
        memberIds: memberIds,
        adminIds: adminIds,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        lastMessage: initialMessage?.msg,
        lastMessageTime: initialMessage != null ? DateTime.now() : null,
      );
      await _groupChatsCollection.doc(groupId).set(newGroupChat.toJsonForCreate());

      if (initialMessage != null) {
        final messageToSend = initialMessage.copyWith(
          id: initialMessage.id.isNotEmpty ? initialMessage.id : uuid.v4(),
          fromId: currentUserId,
          createdAt: DateTime.now(),
        );
        await sendMessage(
          message: messageToSend,
          contextId: groupId,
          isGroupMessage: true,
        );
      }
      return groupId;
    } catch (e) {
      AppLogger.error("Error creating group '$name'", e);
      throw ChatDataSourceException("Error creating group '$name'", cause: e);
    }
  }


  @override
  Stream<List<GroupChatModel>> getGroupChatsStream(String currentUserId) {
    try {
      return _groupChatsCollection
          .where('members', arrayContains: currentUserId)
          .orderBy('last_message_time', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) throw ChatDataSourceException("Malformed data for group chat ${doc.id}");
          return GroupChatModel.fromJson(data, doc.id);
        }).toList();
      }).handleError((error, stackTrace) {
        AppLogger.error("Error in getGroupChatsStream", error, stackTrace);
        throw ChatDataSourceException("Error streaming group chats", cause: error);
      });
    } catch (e) {
      AppLogger.error("Error initializing getGroupChatsStream", e);
      throw ChatDataSourceException("Error initializing group chat stream", cause: e);
    }
  }

  @override
  Future<void> updateGroupChatWithMessage({
    required String groupId,
    required String lastMessage,
    required String messageType,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'last_message': lastMessage,
        'last_message_time': FieldValue.serverTimestamp(),
      };
      await _groupChatsCollection.doc(groupId).update(updateData);
    } catch (e) {
      AppLogger.error("Error updating group chat $groupId", e);
      throw ChatDataSourceException("Error updating group chat $groupId", cause: e);
    }
  }

  @override
  Future<void> updateGroupChatDetails(GroupChatModel groupChatModel) async {
    try {
      final Map<String, dynamic> dataToUpdate = {
        'name': groupChatModel.name,
        'members': groupChatModel.memberIds,
        'admins': groupChatModel.adminIds,
      };
      if (groupChatModel.imageUrl != null) {
        dataToUpdate['image_url'] = groupChatModel.imageUrl;
      } else {
        dataToUpdate['image_url'] = null;
      }
      await _groupChatsCollection.doc(groupChatModel.id).update(dataToUpdate);
    } catch (e) {
      AppLogger.error("Error updating group details for ${groupChatModel.id}", e);
      throw ChatDataSourceException("Error updating group details for ${groupChatModel.id}", cause: e);
    }
  }

  @override
  Future<void> addMembersToGroup(String groupId, List<String> memberIdsToAdd) async {
    try {
      await _groupChatsCollection.doc(groupId).update({
        'members': FieldValue.arrayUnion(memberIdsToAdd),
      });
    } catch (e) {
      AppLogger.error("Error adding members to group $groupId", e);
      throw ChatDataSourceException("Error adding members to group $groupId", cause: e);
    }
  }

  @override
  Future<void> removeMemberFromGroup(String groupId, String memberIdToRemove) async {
    try {
      await _groupChatsCollection.doc(groupId).update({
        'members': FieldValue.arrayRemove([memberIdToRemove]),
        'admins': FieldValue.arrayRemove([memberIdToRemove]),
      });
    } catch (e) {
      AppLogger.error("Error removing member $memberIdToRemove from group $groupId", e);
      throw ChatDataSourceException("Error removing member $memberIdToRemove from group $groupId", cause: e);
    }
  }

  @override
  Stream<GroupChatModel?> watchGroupChatById(String groupId) {
    try {
      return _groupChatsCollection
          .doc(groupId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          return GroupChatModel.fromJson(data, snapshot.id);
        } else {
          return null;
        }
      }).handleError((error, stackTrace) {
        AppLogger.error("ChatDataSource: Error in watchGroupChatById stream for group $groupId", error, stackTrace);
        throw ChatDataSourceException("Error watching group $groupId", cause: error);
      });
    } catch (e) {
      AppLogger.error("ChatDataSource: Error initializing watchGroupChatById stream for group $groupId", e);
      throw ChatDataSourceException("Error initializing stream for group $groupId", cause: e);
    }
  }
  // --- Message Operations ---
  @override
  Future<void> sendMessage({
    required MessageModel message,
    required String contextId,
    required bool isGroupMessage,
  }) async {
    final collectionName = isGroupMessage ? 'groups' : 'rooms';
    final messageToSend = message.copyWith(
      id: message.id.isNotEmpty ? message.id : uuid.v4(),
      createdAt: message.createdAt ?? DateTime.now(),
    );

    try {
      // This ensures that if a user sends a message to a chat they previously hid,
      // the chat becomes visible again for them.
      if (!isGroupMessage && message.fromId != 'system') {
        await unhideChatForUser(contextId, message.fromId);
      }

      // Save the message to the subcollection
      await firestore
          .collection(collectionName)
          .doc(contextId)
          .collection('messages')
          .doc(messageToSend.id)
          .set(messageToSend.toJsonForCreate());

      // Determine the preview text for the chat list
      String messagePreview;
      if (messageToSend.type == MessageType.image) {
        messagePreview = '📷 Image';
      } else {
        // For both text and system messages, use the message content as the preview
        messagePreview = messageToSend.msg;
      }

      // Update the parent document with the latest message info
      if (isGroupMessage) {
        await updateGroupChatWithMessage(
            groupId: contextId,
            lastMessage: messagePreview,
            messageType: messageToSend.type.name);
      } else {
        await updateChatRoomWithMessage(
            roomId: contextId,
            lastMessage: messagePreview,
            messageType: messageToSend.type.name);
      }
    } catch (e) {
      AppLogger.error("Error sending message in $contextId", e);
      throw ChatDataSourceException("Error sending message in $contextId", cause: e);
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String roomId) {
    try {
      return _chatRoomsCollection.doc(roomId).collection('messages')
          .orderBy('created_at', descending: true)
          .snapshots(includeMetadataChanges: false)
          .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel.fromJson(data, doc.id);
      }).toList())
          .handleError((error, stackTrace) {
        AppLogger.error("Error in getMessagesStream for room $roomId", error, stackTrace);
        throw ChatDataSourceException("Error streaming messages for room $roomId", cause: error);
      });
    } catch (e) {
      AppLogger.error("Error initializing getMessagesStream for room $roomId", e);
      throw ChatDataSourceException("Error initializing message stream for room $roomId", cause: e);
    }
  }

  @override
  Stream<List<MessageModel>> getGroupMessagesStream(String groupId) {
    try {
      return _groupChatsCollection.doc(groupId).collection('messages')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel.fromJson(data, doc.id);
      }).toList())
          .handleError((error, stackTrace) {
        AppLogger.error("Error in getGroupMessagesStream for group $groupId", error, stackTrace);
        throw ChatDataSourceException("Error streaming messages for group $groupId", cause: error);
      });
    } catch (e) {
      AppLogger.error("Error initializing getGroupMessagesStream for group $groupId", e);
      throw ChatDataSourceException("Error initializing message stream for group $groupId", cause: e);
    }
  }

  @override
  Future<void> markMessageAsRead({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
    required String readerUserId,
  }) async {
    final collectionPath = isGroupMessage ? _groupChatsCollection : _chatRoomsCollection;
    try {
      await collectionPath.doc(contextId).collection('messages').doc(messageId)
          .update({'read_at': FieldValue.serverTimestamp()});
    } catch (e) {
      AppLogger.error("Error marking message $messageId as read in $contextId", e);
      throw ChatDataSourceException("Error marking message $messageId as read in $contextId", cause: e);
    }
  }

  @override
  Future<void> deleteMessage({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
  }) async {
    final collectionPath = isGroupMessage ? _groupChatsCollection : _chatRoomsCollection;
    try {
      await collectionPath.doc(contextId).collection('messages').doc(messageId).delete();
    } catch (e) {
      AppLogger.error("Error deleting message $messageId in $contextId", e);
      throw ChatDataSourceException("Error deleting message $messageId in $contextId", cause: e);
    }
  }

  // --- User Related Operations for Chat ---
  @override
  Future<ChatUserEntity?> getChatUserById(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data == null) throw ChatDataSourceException("Malformed user data for $userId");
        final userModel = UserModel.fromMap(data, docSnapshot.id);
        return _mapUserModelToChatUserEntity(userModel);
      } else {
        return null;
      }
    } catch (e) {
      AppLogger.error("Error loading chat user profile: $userId", e);
      throw ChatDataSourceException("Error loading chat user profile: $userId", cause: e);
    }
  }

  @override
  Stream<List<ChatUserEntity>> getChatUsersStreamByIds(List<String> userIds) {
    if (userIds.isEmpty) return Stream.value([]);
    try {
      return _usersCollection
          .where(FieldPath.documentId, whereIn: userIds)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) throw ChatDataSourceException("Malformed user data in stream for ${doc.id}");
          return _mapUserModelToChatUserEntity(UserModel.fromMap(data, doc.id));
        })
            .toList();
      })
          .handleError((error, stackTrace) {
        AppLogger.error("Error in getChatUsersStreamByIds", error, stackTrace);
        throw ChatDataSourceException("Error streaming chat user profiles", cause: error);
      });
    } catch (e) {
      AppLogger.error("Error initializing getChatUsersStreamByIds", e);
      throw ChatDataSourceException("Error initializing chat user profile stream", cause: e);
    }
  }

  @override
  Future<List<ChatUserEntity>> findChatUsersByNamePrefix(String namePrefix, {List<String> excludeIds = const []}) async {
    if (namePrefix.isEmpty) return [];
    try {
      Query query = _usersCollection
          .where('name', isGreaterThanOrEqualTo: namePrefix)
          .where('name', isLessThanOrEqualTo: '$namePrefix\uf8ff')
          .limit(10);

      if (excludeIds.isNotEmpty) {
        query = query.where(FieldPath.documentId, whereNotIn: excludeIds);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .where((doc) => doc.exists)
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) throw ChatDataSourceException("Malformed user data in search for ${doc.id}");
        return _mapUserModelToChatUserEntity(UserModel.fromMap(data, doc.id));
      })
          .toList();
    } catch (e) {
      AppLogger.error("Error searching users by name '$namePrefix'", e);
      throw ChatDataSourceException("Error searching users by name '$namePrefix'", cause: e);
    }
  }


  // --- Storage Operations ---
  @override
  Future<String> uploadChatImage({
    required File imageFile,
    required String contextId,
    required String uploaderUserId,
  }) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${uuid.v4()}.$fileExtension';
      final ref = firebaseStorage.ref().child('chat_images/$contextId/$uploaderUserId/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      AppLogger.error("Error uploading chat image", e);
      throw ChatDataSourceException("Error uploading chat image", cause: e);
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      final messagesSnapshot = await _groupChatsCollection.doc(groupId).collection('messages').get();
      WriteBatch batch = firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_groupChatsCollection.doc(groupId));

      await batch.commit();
      AppLogger.info("Group $groupId and its messages deleted successfully.");
    } catch (e) {
      AppLogger.error("Error deleting group $groupId", e);
      throw ChatDataSourceException("Failed to delete group", cause: e);
    }
  }

  @override
  Future<void> hideChatForUser(String roomId, String userId) async {
    try {
      await _chatRoomsCollection.doc(roomId).update({
        'hidden_for': FieldValue.arrayUnion([userId])
      });
      AppLogger.info("Chat room $roomId hidden for user $userId.");
    } catch (e) {
      AppLogger.error("Error hiding chat room $roomId for user $userId", e);
      throw ChatDataSourceException("Failed to hide chat", cause: e);
    }
  }

  @override
  Future<void> setChatClearedTimestamp(String roomId, String userId) async {
    try {
      await _chatRoomsCollection.doc(roomId).update({
        'cleared_at.$userId': FieldValue.serverTimestamp(),
      });
      await _chatRoomsCollection.doc(roomId).update({
        'last_message': null,
        'last_message_time': null,
      });
      AppLogger.info("Chat history cleared timestamp set for user $userId in room $roomId.");
    } catch (e) {
      AppLogger.error("Error setting chat cleared timestamp", e);
      throw ChatDataSourceException("Failed to clear chat history", cause: e);
    }
  }

  @override
  Future<void> unhideChatForUser(String roomId, String userId) async {
    try {
      await _chatRoomsCollection.doc(roomId).update({
        'hidden_for': FieldValue.arrayRemove([userId])
      });
      AppLogger.info("Chat room $roomId unhidden for user $userId.");
    } catch (e) {
      AppLogger.error("Error unhiding chat room $roomId for user $userId", e);
      throw ChatDataSourceException("Failed to unhide chat", cause: e);
    }
  }

  @override
  Stream<ChatRoomModel?> watchChatRoomById(String roomId) {
    try {
      return _chatRoomsCollection
          .doc(roomId)
          .snapshots(includeMetadataChanges: false)
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return ChatRoomModel.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id);
        } else {
          return null;
        }
      });
    } catch (e) {
      AppLogger.error("Error watching chat room $roomId", e);
      throw ChatDataSourceException("Failed to watch chat room", cause: e);
    }
  }
}