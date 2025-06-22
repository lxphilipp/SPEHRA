import 'dart:async';
import 'dart:io'; // Für File
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart'; // Wichtig für 'ListEquality' und 'MapEquality'

// Entities
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/group_chat_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/add_members_to_group_usecase.dart';
import '../../domain/usecases/delete_group_usecase.dart';
import '../../domain/usecases/get_group_messages_stream_usecase.dart';
import '../../domain/usecases/remove_member_from_group_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/update_group_chat_details_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/watch_group_chat_by_id_usecase.dart';
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';
// import '../../domain/usecases/update_group_chat_details_usecase.dart';

// Auth Provider
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class GroupChatProvider with ChangeNotifier {
  // --- UseCases und Abhängigkeiten ---
  final WatchGroupChatByIdUseCase _watchGroupChatByIdUseCase;
  final GetGroupMessagesStreamUseCase _getGroupMessagesStreamUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final UploadChatImageUseCase _uploadChatImageUseCase;
  final GetChatUsersStreamByIdsUseCase _getChatUsersStreamByIdsUseCase;
  final AuthenticationProvider _authProvider;
  final UpdateGroupChatDetailsUseCase _updateGroupChatDetailsUseCase;
  final AddMembersToGroupUseCase _addMembersToGroupUseCase;
  final RemoveMemberFromGroupUseCase _removeMemberFromGroupUseCase;
  final DeleteGroupUseCase _deleteGroupUseCase;


  final String groupId;

  // --- Konstruktor ---
  GroupChatProvider({
    required this.groupId,
    required WatchGroupChatByIdUseCase watchGroupChatByIdUseCase,
    required GetGroupMessagesStreamUseCase getGroupMessagesStreamUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required UploadChatImageUseCase uploadChatImageUseCase,
    required GetChatUsersStreamByIdsUseCase getChatUsersStreamByIdsUseCase,
    required UpdateGroupChatDetailsUseCase updateGroupChatDetailsUseCase,
    required AddMembersToGroupUseCase addMembersToGroupUseCase,
    required RemoveMemberFromGroupUseCase removeMemberFromGroupUseCase,
    required AuthenticationProvider authProvider,
    required DeleteGroupUseCase deleteGroupUseCase,
  })  : _watchGroupChatByIdUseCase = watchGroupChatByIdUseCase,
        _getGroupMessagesStreamUseCase = getGroupMessagesStreamUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _uploadChatImageUseCase = uploadChatImageUseCase,
        _getChatUsersStreamByIdsUseCase = getChatUsersStreamByIdsUseCase,
        _updateGroupChatDetailsUseCase = updateGroupChatDetailsUseCase,
        _addMembersToGroupUseCase = addMembersToGroupUseCase,
        _removeMemberFromGroupUseCase = removeMemberFromGroupUseCase,
        _deleteGroupUseCase = deleteGroupUseCase,
        _authProvider = authProvider {
    AppLogger.debug("GroupChatProvider for groupId: $groupId initialized.");
    _subscribeToGroupDetails(); // Startet den Haupt-Stream
  }

  // --- Zustand (State) des Providers ---
  GroupChatEntity? _groupDetails;
  List<MessageEntity> _messages = [];
  Map<String, ChatUserEntity> _memberDetailsMap = {};
  bool _isLoadingInitialData = true;
  bool _isSendingMessage = false;
  String? _error;
  File? _imagePreview;

  // --- Stream Subscriptions ---
  StreamSubscription<GroupChatEntity?>? _groupDetailsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  StreamSubscription<List<ChatUserEntity>>? _memberDetailsSubscription;

  // --- Getter ---
  GroupChatEntity? get groupDetails => _groupDetails;
  List<MessageEntity> get messages => _messages;
  Map<String, ChatUserEntity> get memberDetailsMap => _memberDetailsMap;
  bool get isLoadingInitialData => _isLoadingInitialData;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  File? get imagePreview => _imagePreview;
  String get currentUserId => _authProvider.currentUserId ?? '';

  // --- Kernlogik & Subscriptions (ÜBERARBEITET) ---

  void _subscribeToGroupDetails() {
    _isLoadingInitialData = true;
    _error = null;
    notifyListeners();

    _groupDetailsSubscription?.cancel();
    _groupDetailsSubscription = _watchGroupChatByIdUseCase(groupId: groupId).listen(
          (newDetails) {
        if (!_isValidState) return;

        if (newDetails == null) {
          _handleGroupNotFoundOrDeleted("Gruppe nicht gefunden oder gelöscht.");
          return;
        }

        // Deep Equality Check, um unnötige Rebuilds zu vermeiden.
        // Setzt voraus, dass GroupChatEntity Equatable ist.
        final bool hasDetailsChanged = _groupDetails != newDetails;
        final bool haveMembersChanged = !const ListEquality().equals(_groupDetails?.memberIds, newDetails.memberIds);

        // Zustand nur aktualisieren, wenn sich wirklich etwas geändert hat.
        if (!hasDetailsChanged) {
          AppLogger.trace("Group details for $groupId received, but no changes detected.");
          // Sicherstellen, dass der Lade-Spinner beim ersten (unveränderten) Event verschwindet.
          if (_isLoadingInitialData) {
            _isLoadingInitialData = false;
            notifyListeners();
          }
          return;
        }

        _groupDetails = newDetails;
        AppLogger.debug("GroupChatProvider: Updated group details for $groupId: ${newDetails.name}");

        // Nur wenn sich die Mitgliederliste geändert hat, das Mitglieder-Abo neu starten.
        if (haveMembersChanged) {
          if (newDetails.memberIds.isNotEmpty) {
            _subscribeToMemberDetails(newDetails.memberIds);
          } else {
            // Falls alle Mitglieder entfernt wurden, Abo stoppen und Map leeren.
            _memberDetailsSubscription?.cancel();
            _memberDetailsMap = {};
          }
        }

        // Nachrichten-Abo nur starten, wenn es noch nicht läuft.
        if (_messagesSubscription == null) {
          _subscribeToMessages();
        }

        if (_isLoadingInitialData) _isLoadingInitialData = false;

        _error = null;
        notifyListeners();
      },
      onError: (e, stackTrace) {
        if (!_isValidState) return;
        AppLogger.error("GroupChatProvider: Error in group details stream for $groupId", e, stackTrace);
        _handleGroupNotFoundOrDeleted("Fehler beim Laden der Gruppendetails.");
      },
    );
  }

  void _subscribeToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _getGroupMessagesStreamUseCase(groupId: groupId).listen(
          (loadedMessages) {
        if (!_isValidState) return;

        // Verhindert Rebuild, wenn die Liste identisch ist (z.B. durch Metadaten-Echo).
        // Setzt voraus, dass MessageEntity Equatable ist.
        if (const ListEquality().equals(_messages, loadedMessages)) {
          AppLogger.trace("Messages received, but list is identical. Skipping notifyListeners.");
          return;
        }

        _messages = loadedMessages;
        AppLogger.debug("GroupChatProvider: Received ${loadedMessages.length} messages for groupId: $groupId");
        notifyListeners();
      },
      onError: (e, stackTrace) {
        if (!_isValidState) return;
        AppLogger.error("GroupChatProvider: Error loading messages for groupId: $groupId", e, stackTrace);
        _setError("Fehler beim Laden der Nachrichten.");
      },
    );
  }

  void _subscribeToMemberDetails(List<String> memberIds) {
    _memberDetailsSubscription?.cancel();
    _memberDetailsSubscription = _getChatUsersStreamByIdsUseCase(userIds: memberIds).listen(
          (members) {
        if (!_isValidState) return;
        final newMemberMap = {for (var member in members) member.id: member};

        // Verhindert Rebuild, wenn die Map der Mitgliederdetails identisch ist.
        // Setzt voraus, dass ChatUserEntity Equatable ist.
        if (const MapEquality().equals(_memberDetailsMap, newMemberMap)) {
          AppLogger.trace("Member details received, but map is identical. Skipping notifyListeners.");
          return;
        }

        _memberDetailsMap = newMemberMap;
        AppLogger.debug("GroupChatProvider: Loaded/Updated ${members.length} member details for groupId: $groupId");
        notifyListeners();
      },
      onError: (e, stackTrace) {
        if (!_isValidState) return;
        AppLogger.error("GroupChatProvider: Error loading member details for groupId: $groupId", e, stackTrace);
      },
    );
  }

  void _handleGroupNotFoundOrDeleted(String errorMessage) {
    _error = errorMessage;
    _groupDetails = null;
    _messages = [];
    _memberDetailsMap = {};
    _isLoadingInitialData = false;
    _messagesSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    notifyListeners();
  }

  // --- Public Aktionen ---
  void forceReloadData() {
    AppLogger.info("GroupChatProvider: forceReloadData called for $groupId.");
    _groupDetailsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    _groupDetails = null;
    _messages = [];
    _memberDetailsMap = {};
    _subscribeToGroupDetails();
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || currentUserId.isEmpty || _groupDetails == null) return;

    _isSendingMessage = true;
    _setError(null);
    notifyListeners();

    final message = MessageEntity(
      id: '',
      fromId: currentUserId,
      toId: groupId,
      msg: text.trim(),
      type: 'text',
      createdAt: DateTime.now(),
    );

    try {
      await _sendMessageUseCase(message: message, contextId: groupId, isGroupMessage: true);
      AppLogger.info("GroupChatProvider: Text message sent to group $groupId");
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatProvider: Error sending text message to group $groupId", e, stackTrace);
      _setError("Nachricht konnte nicht gesendet werden.");
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  void setImageForPreview(File? imageFile) {
    _imagePreview = imageFile;
    notifyListeners();
  }

  Future<void> sendSelectedImage() async {
    if (_imagePreview == null || currentUserId.isEmpty || _groupDetails == null) return;

    _isSendingMessage = true;
    _setError(null);
    File imageToSend = _imagePreview!;
    setImageForPreview(null); // Vorschau sofort entfernen, UI wird durch notifyListeners aktualisiert
    notifyListeners();

    try {
      final imageUrl = await _uploadChatImageUseCase(
        imageFile: imageToSend,
        contextId: groupId,
        uploaderUserId: currentUserId,
      );

      if (imageUrl != null) {
        final message = MessageEntity(id: '', fromId: currentUserId, toId: groupId, msg: imageUrl, type: 'image', createdAt: DateTime.now());
        await _sendMessageUseCase(message: message, contextId: groupId, isGroupMessage: true);
        AppLogger.info("GroupChatProvider: Image message sent to group $groupId");
      } else {
        _setError("Bild-Upload fehlgeschlagen.");
      }
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatProvider: Error sending image message to group $groupId", e, stackTrace);
      _setError("Bildnachricht konnte nicht gesendet werden.");
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  ChatUserEntity? getMemberDetail(String userId) {
    return _memberDetailsMap[userId];
  }

  void _setError(String? message) {
    if (_error != message) {
      _error = message;
    }
  }

  // --- Dispose-Logik ---
  bool _isValidState = true;
  bool get isValidState => _isValidState;

  bool get amIAdmin => groupDetails?.adminIds.contains(currentUserId) ?? false;

  Future<void> addMembers(List<String> userIdsToAdd) async {
    if (!amIAdmin) return; // Sicherheitscheck
    try {
      await _addMembersToGroupUseCase(groupId: groupId, memberIdsToAdd: userIdsToAdd);
      AppLogger.info("Added ${userIdsToAdd.length} members to group $groupId.");
      // Der Stream _groupDetailsSubscription wird dies automatisch aktualisieren.
    } catch (e, s) {
      AppLogger.error("Error adding members to group $groupId", e, s);
      _setError("Could not add members.");
      notifyListeners(); // Fehler anzeigen
    }
  }

  Future<void> removeMember(String memberIdToRemove) async {
    // Admins können andere entfernen. Jeder kann sich selbst entfernen (Gruppe verlassen).
    if (!amIAdmin && memberIdToRemove != currentUserId) return;

    // Verhindern, dass der letzte Admin die Gruppe verlässt/entfernt wird, wenn er der einzige Admin ist.
    if (groupDetails?.adminIds.length == 1 && groupDetails?.adminIds.first == memberIdToRemove) {
      _setError("The last admin cannot be removed.");
      notifyListeners();
      return;
    }

    try {
      await _removeMemberFromGroupUseCase(groupId: groupId, memberIdToRemove: memberIdToRemove);
      AppLogger.info("Removed member $memberIdToRemove from group $groupId.");
    } catch (e, s) {
      AppLogger.error("Error removing member from group $groupId", e, s);
      _setError("Could not remove member.");
      notifyListeners();
    }
  }

  Future<void> updateGroupName(String newName) async {
    if (!amIAdmin || groupDetails == null) return;
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == groupDetails!.name) return;

    try {
      // Erstelle eine aktualisierte Entity und übergebe sie an den UseCase
      final updatedGroup = groupDetails!.copyWith(name: trimmedName);
      await _updateGroupChatDetailsUseCase(groupChatEntity: updatedGroup);
      AppLogger.info("Updated group name for $groupId to '$trimmedName'.");
    } catch (e, s) {
      AppLogger.error("Error updating group name for $groupId", e, s);
      _setError("Could not update group name.");
      notifyListeners();
    }
  }

  Future<void> leaveOrDeleteGroup() async {
    if (groupDetails == null || currentUserId.isEmpty) return;

    final bool isLastMember = groupDetails!.memberIds.length == 1 &&
        groupDetails!.memberIds.first == currentUserId;

    if (isLastMember) {
      // Spezialfall 2: Letztes Mitglied -> Gruppe löschen
      AppLogger.info("Last member leaving. Deleting group $groupId.");
      try {
        await _deleteGroupUseCase(groupId: groupId);
        // Fehler wird im UseCase/Repo geloggt, hier brauchen wir keine UI-Meldung,
        // da wir sowieso wegnavigieren.
      } catch (e) {
        _setError("Failed to delete the group.");
        notifyListeners();
      }
    } else {
      // Normalfall oder letzter Admin (der nicht letztes Mitglied ist) -> Nur verlassen
      AppLogger.info("Member $currentUserId leaving group $groupId.");
      try {
        await _removeMemberFromGroupUseCase(groupId: groupId, memberIdToRemove: currentUserId);
      } catch (e) {
        _setError("Failed to leave the group.");
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    AppLogger.debug("GroupChatProvider for groupId: $groupId disposing...");
    _isValidState = false;
    _groupDetailsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    super.dispose();
    AppLogger.debug("GroupChatProvider for groupId: $groupId disposed.");
  }
}