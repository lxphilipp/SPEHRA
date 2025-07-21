import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// Models und Entities für Chat
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/message_entity.dart';
import '../models/chat_room_model.dart';
import '../models/group_chat_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/chat_user_entity.dart';

// UserModel aus dem Auth-Feature für das Parsen von User-Dokumenten
import '../../../auth/data/models/user_model.dart';


abstract class ChatRemoteDataSource {
  // --- Chat Room Operations (1-zu-1 Chats) ---

  /// Erstellt einen neuen Chatraum zwischen dem [currentUserId] und dem [partnerUserId]
  /// oder gibt die ID eines existierenden Raums zurück.
  /// [initialMessage] ist optional.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<String> createOrGetChatRoom({
    required String currentUserId,
    required String partnerUserId,
    MessageModel? initialMessage,
  });

  /// Streamt eine Liste von ChatRoomModels, an denen der [currentUserId] beteiligt ist.
  /// Der Stream emittiert Fehler als [ChatDataSourceException].
  Stream<List<ChatRoomModel>> getChatRoomsStream(String currentUserId);

  /// Aktualisiert die 'last_message' und 'last_message_time' eines Chatraums.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
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

  /// Erstellt eine neue Chat-Gruppe.
  /// [currentUserId] wird für die Erstellung der initialMessage benötigt.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<String> createGroupChat({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    required String currentUserId, // Benötigt für initialMessage.fromId
    String? imageUrl,
    MessageModel? initialMessage,
  });

  /// Streamt eine Liste von GroupChatModels, in denen der [currentUserId] Mitglied ist.
  /// Der Stream emittiert Fehler als [ChatDataSourceException].
  Stream<List<GroupChatModel>> getGroupChatsStream(String currentUserId);

  /// Aktualisiert die 'last_message' und 'last_message_time' einer Gruppe.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> updateGroupChatWithMessage({
    required String groupId,
    required String lastMessage,
    required String messageType,
  });

  /// Aktualisiert die allgemeinen Informationen einer Gruppe.
  /// Das [groupChatModel] sollte die aktualisierten Daten enthalten.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> updateGroupChatDetails(GroupChatModel groupChatModel);

  /// Fügt Mitglieder zu einer bestehenden Gruppe hinzu.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> addMembersToGroup(String groupId, List<String> memberIdsToAdd);

  /// Entfernt ein Mitglied aus einer Gruppe.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> removeMemberFromGroup(String groupId, String memberIdToRemove);


  // --- Message Operations (für 1-zu-1 und Gruppen) ---

  /// Sendet eine Nachricht.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> sendMessage({
    required MessageModel message,
    required String contextId, // roomId oder groupId
    required bool isGroupMessage,
  });

  /// Streamt Nachrichten für einen gegebenen Chatraum (1-zu-1).
  /// Der Stream emittiert Fehler als [ChatDataSourceException].
  Stream<List<MessageModel>> getMessagesStream(String roomId);

  /// Streamt Nachrichten für eine gegebene Gruppe.
  /// Der Stream emittiert Fehler als [ChatDataSourceException].
  Stream<List<MessageModel>> getGroupMessagesStream(String groupId);

  /// Markiert eine Nachricht als gelesen.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> markMessageAsRead({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
    required String readerUserId,
  });

  /// Löscht eine Nachricht.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<void> deleteMessage({
    required String contextId,
    required String messageId,
    required bool isGroupMessage,
  });

  // --- User Related Operations for Chat ---

  /// Holt eine einzelne ChatUserEntity anhand der User-ID.
  /// Gibt null zurück, wenn der User nicht gefunden wird.
  /// Wirft eine [ChatDataSourceException] bei anderen Fehlern.
  Future<ChatUserEntity?> getChatUserById(String userId);

  /// Streamt eine Liste von ChatUserEntities für eine Liste von User-IDs.
  /// Der Stream emittiert Fehler als [ChatDataSourceException].
  Stream<List<ChatUserEntity>> getChatUsersStreamByIds(List<String> userIds);

  /// Sucht Benutzer, deren Name mit dem [namePrefix] beginnt.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<List<ChatUserEntity>> findChatUsersByNamePrefix(String namePrefix, {List<String> excludeIds});

  // --- Storage Operations ---

  /// Lädt ein Bild in den Storage hoch.
  /// Gibt die herunterladbare URL des Bildes zurück.
  /// Wirft eine [ChatDataSourceException] bei Fehlern.
  Future<String> uploadChatImage({
    required File imageFile,
    required String contextId, // roomId oder groupId
    required String uploaderUserId,
  });

  /// Streamt ein einzelnes GroupChatModel anhand der ID.
  /// Emittiert null, wenn die Gruppe nicht existiert oder gelöscht wird.
  Stream<GroupChatModel?> watchGroupChatById(String groupId);

  Future<void> deleteGroup(String groupId);

}

/// Benutzerdefinierte Exception für Fehler in der Chat-Datenquelle.
class ChatDataSourceException implements Exception {
  final String message;
  final dynamic cause; // Optionale Ursache, z.B. die ursprüngliche FirebaseException

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
      print("ChatDataSource Error in updateChatRoomWithMessage: $e");
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
      print("ChatDataSource Error in createGroupChat: $e");
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
        print("ChatDataSource Error in getGroupChatsStream: $error, Stack: $stackTrace");
        throw ChatDataSourceException("Error streaming group chats", cause: error);
      });
    } catch (e) {
      print("ChatDataSource Error initializing getGroupChatsStream: $e");
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
      print("ChatDataSource Error in updateGroupChatWithMessage: $e");
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
      print("ChatDataSource Error in updateGroupChatDetails: $e");
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
      print("ChatDataSource Error in addMembersToGroup: $e");
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
      print("ChatDataSource Error in removeMemberFromGroup: $e");
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
      print("ChatDataSource Error in sendMessage: $e");
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
        print("ChatDataSource Error in getMessagesStream for room $roomId: $error, Stack: $stackTrace");
        throw ChatDataSourceException("Error streaming messages for room $roomId", cause: error);
      });
    } catch (e) {
      print("ChatDataSource Error initializing getMessagesStream for room $roomId: $e");
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
        print("ChatDataSource Error in getGroupMessagesStream for group $groupId: $error, Stack: $stackTrace");
        throw ChatDataSourceException("Error streaming messages for group $groupId", cause: error);
      });
    } catch (e) {
      print("ChatDataSource Error initializing getGroupMessagesStream for group $groupId: $e");
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
      print("ChatDataSource Error in markMessageAsRead: $e");
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
      print("ChatDataSource Error in deleteMessage: $e");
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
      print("ChatDataSource Error in getChatUserById: $e");
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
        print("ChatDataSource Error in getChatUsersStreamByIds: $error, Stack: $stackTrace");
        throw ChatDataSourceException("Error streaming chat user profiles", cause: error);
      });
    } catch (e) {
      print("ChatDataSource Error initializing getChatUsersStreamByIds: $e");
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
      print("ChatDataSource Error in findChatUsersByNamePrefix: $e");
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
      print("ChatDataSource Error in uploadChatImage: $e");
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