import 'dart:async';
import 'dart:io'; // Für File
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart'; // Wichtig für 'ListEquality' und 'MapEquality'
import 'package:flutter_sdg/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';

// Entities
import '../../../challenges/domain/repositories/challenge_repository.dart';
import '../../../invites/domain/entities/invite_entity.dart';
import '../../../invites/domain/usecases/accept_challenge_invite_usecase.dart';
import '../../../invites/domain/usecases/create_challenge_invite_usecase.dart';
import '../../../invites/domain/usecases/decline_challenge_invite_usecase.dart';
import '../../../invites/domain/usecases/get_invites_for_context_usecase.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/group_chat_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/add_members_to_group_usecase.dart';
import '../../domain/usecases/delete_group_usecase.dart';
import '../../domain/usecases/get_combined_chat_items_usecase.dart';
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
  final SendMessageUseCase _sendMessageUseCase;
  final UploadChatImageUseCase _uploadChatImageUseCase;
  final GetChatUsersStreamByIdsUseCase _getChatUsersStreamByIdsUseCase;
  final AuthenticationProvider _authProvider;
  final UpdateGroupChatDetailsUseCase _updateGroupChatDetailsUseCase;
  final AddMembersToGroupUseCase _addMembersToGroupUseCase;
  final RemoveMemberFromGroupUseCase _removeMemberFromGroupUseCase;
  final DeleteGroupUseCase _deleteGroupUseCase;
  final GetCombinedChatItemsUseCase _getCombinedChatItemsUseCase;
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  final AcceptChallengeInviteUseCase _acceptChallengeInviteUseCase;
  final DeclineChallengeInviteUseCase _declineChallengeInviteUseCase;
  final CreateChallengeInviteUseCase _createChallengeInviteUseCase;

  final String groupId;

  // --- Konstruktor ---
  GroupChatProvider({
    required this.groupId,
    required WatchGroupChatByIdUseCase watchGroupChatByIdUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required UploadChatImageUseCase uploadChatImageUseCase,
    required GetChatUsersStreamByIdsUseCase getChatUsersStreamByIdsUseCase,
    required UpdateGroupChatDetailsUseCase updateGroupChatDetailsUseCase,
    required AddMembersToGroupUseCase addMembersToGroupUseCase,
    required RemoveMemberFromGroupUseCase removeMemberFromGroupUseCase,
    required AuthenticationProvider authProvider,
    required DeleteGroupUseCase deleteGroupUseCase,
    required CreateChallengeInviteUseCase createChallengeInviteUseCase,
    required GetChallengeByIdUseCase getChallengeByIdUseCase,
    required AcceptChallengeInviteUseCase acceptChallengeInviteUseCase,
    required DeclineChallengeInviteUseCase declineChallengeInviteUseCase,
    required GetCombinedChatItemsUseCase getCombinedChatItemsUseCase,
  })  : _watchGroupChatByIdUseCase = watchGroupChatByIdUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _uploadChatImageUseCase = uploadChatImageUseCase,
        _getChatUsersStreamByIdsUseCase = getChatUsersStreamByIdsUseCase,
        _updateGroupChatDetailsUseCase = updateGroupChatDetailsUseCase,
        _addMembersToGroupUseCase = addMembersToGroupUseCase,
        _removeMemberFromGroupUseCase = removeMemberFromGroupUseCase,
        _deleteGroupUseCase = deleteGroupUseCase,
        _authProvider = authProvider,
        _getCombinedChatItemsUseCase = getCombinedChatItemsUseCase,
        _getChallengeByIdUseCase = getChallengeByIdUseCase,
        _acceptChallengeInviteUseCase = acceptChallengeInviteUseCase,
        _declineChallengeInviteUseCase = declineChallengeInviteUseCase,
        _createChallengeInviteUseCase = createChallengeInviteUseCase
  {
    AppLogger.debug("GroupChatProvider for groupId: $groupId initialized.");
    _subscribeToGroupDetails();
  }

  // --- Zustand (State) des Providers ---
  GroupChatEntity? _groupDetails;
  List<dynamic> _chatItems = [];
  Map<String, ChatUserEntity> _memberDetailsMap = {};
  bool _isLoadingInitialData = true;
  bool _isSendingMessage = false;
  String? _error;
  File? _imagePreview;

  // --- Stream Subscriptions ---
  StreamSubscription<GroupChatEntity?>? _groupDetailsSubscription;
  StreamSubscription<List<ChatUserEntity>>? _memberDetailsSubscription;
  StreamSubscription? _chatItemsSubscription;

  // --- Getter ---
  GroupChatEntity? get groupDetails => _groupDetails;
  List<dynamic> get chatItems => _chatItems;
  Map<String, ChatUserEntity> get memberDetailsMap => _memberDetailsMap;
  bool get isLoadingInitialData => _isLoadingInitialData;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  File? get imagePreview => _imagePreview;
  String get currentUserId => _authProvider.currentUserId ?? '';

  // --- Kernlogik & Subscriptions (ÜBERARBEITET) ---

  void _subscribeToChatItems() {
    _chatItemsSubscription?.cancel();
    _chatItemsSubscription = _getCombinedChatItemsUseCase(groupId).listen((items) {
      if (!_isValidState) return;

      // Using ListEquality to prevent unnecessary rebuilds
      if (const ListEquality().equals(_chatItems, items)) {
        return;
      }

      _chatItems = items;
      notifyListeners();
    }, onError: (e) {
      if (!_isValidState) return;
      AppLogger.error("Error in combined chat items stream for group $groupId: $e");
      _setError("Fehler beim Laden des Chats.");
    });
  }

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

        if (_chatItemsSubscription == null) {
          _subscribeToChatItems();
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

  void _subscribeToMemberDetails(List<String> memberIds) {
    _memberDetailsSubscription?.cancel();
    _memberDetailsSubscription = _getChatUsersStreamByIdsUseCase(userIds: memberIds).listen(
          (members) {
        if (!_isValidState) return;
        final newMemberMap = {for (var member in members) member.id: member};

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
    _chatItems = [];
    _memberDetailsMap = {};
    _isLoadingInitialData = false;
    _chatItemsSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    notifyListeners();
  }

  // --- Public Aktionen ---
  void forceReloadData() {
    AppLogger.info("GroupChatProvider: forceReloadData called for $groupId.");
    _groupDetailsSubscription?.cancel();
    _chatItemsSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    _groupDetails = null;
    _chatItems = [];
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
        await _removeMemberFromGroupUseCase(
            groupId: groupId, memberIdToRemove: currentUserId);
      } catch (e) {
        _setError("Failed to leave the group.");
        notifyListeners();
      }
    }
  }
  Future<void> startGroupChallenge(String challengeId) async {
    final inviterId = _authProvider.currentUserId;

    if (inviterId == null || _groupDetails == null) {
      AppLogger.error("Kann Challenge nicht starten: User oder Gruppendetails fehlen.");
      return;
    }

    final params = CreateInviteParams(
      inviterId: inviterId,
      challengeId: challengeId,
      context: InviteContext.group,
      contextId: _groupDetails!.id,
      recipientIds: _groupDetails!.memberIds,
    );

    try {
      await _createChallengeInviteUseCase(params);
      AppLogger.info("Challenge-Einladung für Gruppe ${_groupDetails!.id} wurde erstellt.");
    } catch (e) {
      AppLogger.error("Fehler beim Erstellen der Challenge-Einladung: $e");
    }
  }

// In der GroupChatProvider-Klasse

  /// Akzeptiert eine Challenge-Einladung im Namen des aktuellen Nutzers.
  Future<void> acceptChallengeInvite(InviteEntity invite) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _setError("Fehler: Du bist nicht eingeloggt.");
      notifyListeners();
      return;
    }

    // Temporären Ladezustand für die UI setzen (optional, aber empfohlen)
    // Du könntest hier einen State wie `isAcceptingInvite = true` setzen.

    try {
      AppLogger.info("Versuche, Challenge ${invite.targetId} zu akzeptieren...");

      // Schritt 1: Hol die vollständigen Challenge-Details
      final challenge = await _getChallengeByIdUseCase(invite.targetId);

      // Schritt 2: Prüfe, ob die Challenge gefunden wurde, und gib eine klare Fehlermeldung aus
      if (challenge == null) {
        AppLogger.error("Challenge mit ID ${invite.targetId} nicht gefunden.");
        _setError("Fehler: Diese Challenge konnte nicht gefunden werden.");
        notifyListeners();
        return;
      }

      AppLogger.info("Challenge '${challenge.title}' gefunden. Starte Akzeptanz-Prozess...");

      // Schritt 3: Rufe den Use Case auf
      final params = AcceptInviteParams(
        inviteId: invite.id,
        userId: userId,
        challenge: challenge,
      );
      await _acceptChallengeInviteUseCase(params);

      AppLogger.info("Challenge-Einladung erfolgreich akzeptiert.");
      // Die UI aktualisiert sich automatisch durch die Streams, die auf die
      // Status-Änderung in der InviteEntity und die neue Challenge-Progression hören.

    } catch (e) {
      // Fange alle anderen unerwarteten Fehler ab
      AppLogger.error("Unerwarteter Fehler beim Akzeptieren der Einladung: $e");
      _setError("Ein unerwarteter Fehler ist aufgetreten.");
      notifyListeners();
    } finally {
      // Ladezustand beenden (falls du einen verwendest)
      // isAcceptingInvite = false;
      // notifyListeners();
    }
  }

  /// Lehnt eine Challenge-Einladung im Namen des aktuellen Nutzers ab.
  Future<void> declineChallengeInvite(InviteEntity invite) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) return;

    final params = DeclineInviteParams(inviteId: invite.id, userId: userId);
    await _declineChallengeInviteUseCase(params);
  }

  @override
  void dispose() {
    AppLogger.debug("GroupChatProvider for groupId: $groupId disposing...");
    _isValidState = false;
    _groupDetailsSubscription?.cancel();
    _chatItemsSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    super.dispose();
    AppLogger.debug("GroupChatProvider for groupId: $groupId disposed.");
  }
}