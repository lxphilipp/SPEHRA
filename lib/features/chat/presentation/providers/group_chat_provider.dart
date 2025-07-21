// lib/features/chat/presentation/providers/group_chat_provider.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/create_group_challenge_progress_usecase.dart';
import 'package:rxdart/rxdart.dart';

// Entities
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/domain/entities/group_challenge_progress_entity.dart';
import '../../../challenges/domain/repositories/challenge_repository.dart';
import '../../../challenges/domain/usecases/watch_group_progress_by_context_id_usecase.dart';
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
import '../../domain/usecases/remove_member_from_group_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/update_group_chat_details_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/watch_group_chat_by_id_usecase.dart';
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';

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
  final WatchGroupProgressByContextIdUseCase _watchGroupProgressByContextIdUseCase; // NEU

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
    required WatchGroupProgressByContextIdUseCase watchGroupProgressByContextIdUseCase, // NEU
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
        _createChallengeInviteUseCase = createChallengeInviteUseCase,
        _watchGroupProgressByContextIdUseCase = watchGroupProgressByContextIdUseCase { // NEU
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
  List<GroupChallengeProgressEntity> _activeChallenges = [];
  final Map<String, ChallengeEntity> _challengeDetailsForInvites = {};


  // --- Stream Subscriptions ---
  StreamSubscription<GroupChatEntity?>? _groupDetailsSubscription;
  StreamSubscription<List<ChatUserEntity>>? _memberDetailsSubscription;
  StreamSubscription? _chatItemsSubscription;
  StreamSubscription? _challengeProgressSubscription;

  // --- Getter ---
  GroupChatEntity? get groupDetails => _groupDetails;
  List<dynamic> get chatItems => _chatItems;
  Map<String, ChatUserEntity> get memberDetailsMap => _memberDetailsMap;
  bool get isLoadingInitialData => _isLoadingInitialData;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  File? get imagePreview => _imagePreview;
  String get currentUserId => _authProvider.currentUserId ?? '';
  bool get amIAdmin => groupDetails?.adminIds.contains(currentUserId) ?? false;
  List<GroupChallengeProgressEntity> get activeChallenges => _activeChallenges;
  ChallengeEntity? getChallengeDetailsForInvite(String challengeId) => _challengeDetailsForInvites[challengeId];


  // --- Kernlogik & Subscriptions ---
  void _subscribeToChatItems() {
    _chatItemsSubscription?.cancel();
    _chatItemsSubscription = _getCombinedChatItemsUseCase(groupId).listen((items) {
      if (!_isValidState) return;
      final filteredItems = items.where((item) => item is! GroupChallengeProgressEntity).toList();
      if (const ListEquality().equals(_chatItems, filteredItems)) return;
      _chatItems = filteredItems;
      _fetchChallengeDetailsForInvites(filteredItems);
      notifyListeners();
    }, onError: (e) {
      if (!_isValidState) return;
      AppLogger.error("Error in combined chat items stream for group $groupId: $e");
      _setError("Error loading chat.");
    });
  }

  void _fetchChallengeDetailsForInvites(List<dynamic> items) {
    for (var item in items.whereType<InviteEntity>()) {
      if (!_challengeDetailsForInvites.containsKey(item.targetId)) {
        _getChallengeByIdUseCase(item.targetId).then((challenge) {
          if (challenge != null && _isValidState) {
            _challengeDetailsForInvites[item.targetId] = challenge;
            notifyListeners();
          }
        });
      }
    }
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
          _handleGroupNotFoundOrDeleted("Group not found or deleted.");
          return;
        }
        final bool hasDetailsChanged = _groupDetails != newDetails;
        final bool haveMembersChanged = !const ListEquality().equals(_groupDetails?.memberIds, newDetails.memberIds);

        // HIER NEU: Separates Abo für den Challenge-Fortschritt starten
        if (_challengeProgressSubscription == null) {
          _subscribeToChallengeProgress();
        }

        if (!hasDetailsChanged) {
          if (_isLoadingInitialData) {
            _isLoadingInitialData = false;
            notifyListeners();
          }
          return;
        }
        _groupDetails = newDetails;
        if (haveMembersChanged) {
          if (newDetails.memberIds.isNotEmpty) {
            _subscribeToMemberDetails(newDetails.memberIds);
          } else {
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
        _handleGroupNotFoundOrDeleted("Error loading group details.");
      },
    );
  }

  // HIER IST DIE METHODE
  void _subscribeToChallengeProgress() {
    _challengeProgressSubscription?.cancel();
    _challengeProgressSubscription = _watchGroupProgressByContextIdUseCase(groupId)
        .asStream()
        .switchMap((stream) => stream)
        .listen((challenges) {
      if (!_isValidState) return;
      if (!const ListEquality().equals(_activeChallenges, challenges)) {
        _activeChallenges = challenges;
        notifyListeners();
      }
    }, onError: (e) {
      AppLogger.error("Error in group challenge progress stream for group $groupId: $e");
    });
  }


  void _subscribeToMemberDetails(List<String> memberIds) {
    AppLogger.debug("GroupChatProvider: Subscribing to member details for ${memberIds.length} members.");
    _memberDetailsSubscription?.cancel();
    _memberDetailsSubscription = _getChatUsersStreamByIdsUseCase(userIds: memberIds).listen(
          (members) {
        if (!_isValidState) return;
        final newMemberMap = {for (var member in members) member.id: member};
        if (const MapEquality().equals(_memberDetailsMap, newMemberMap)) return;
        _memberDetailsMap = newMemberMap;
        notifyListeners();
      },
      onError: (e, stackTrace) {
        if (!_isValidState) return;
        AppLogger.error("Error loading member details for group $groupId", e, stackTrace);
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
    _challengeProgressSubscription?.cancel(); // Auch hier beenden
    notifyListeners();
  }

  void _setError(String? message) {
    if (_error != message) {
      _error = message;
    }
  }

  // --- Public Aktionen ---
  void forceReloadData() {
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
    final message = MessageEntity(id: '', fromId: currentUserId, toId: groupId, msg: text.trim(), type: MessageType.text, createdAt: DateTime.now());
    try {
      await _sendMessageUseCase(message: message, contextId: groupId, isGroupMessage: true);
    } catch (e, stackTrace) {
      AppLogger.error("Error sending text message to group $groupId", e, stackTrace);
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
    setImageForPreview(null);
    notifyListeners();
    try {
      final imageUrl = await _uploadChatImageUseCase(imageFile: imageToSend, contextId: groupId, uploaderUserId: currentUserId);
      if (imageUrl != null) {
        final message = MessageEntity(id: '', fromId: currentUserId, toId: groupId, msg: imageUrl, type: MessageType.image, createdAt: DateTime.now());
        await _sendMessageUseCase(message: message, contextId: groupId, isGroupMessage: true);
      } else {
        _setError("Bild-Upload fehlgeschlagen.");
      }
    } catch (e, stackTrace) {
      AppLogger.error("Error sending image message to group $groupId", e, stackTrace);
      _setError("Bildnachricht konnte nicht gesendet werden.");
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  ChatUserEntity? getMemberDetail(String userId) {
    return _memberDetailsMap[userId];
  }

  Future<void> addMembers(List<String> userIdsToAdd) async {
    if (!amIAdmin) return;
    try {
      await _addMembersToGroupUseCase(groupId: groupId, memberIdsToAdd: userIdsToAdd);
    } catch (e, s) {
      AppLogger.error("Error adding members to group $groupId", e, s);
      _setError("Could not add members.");
      notifyListeners();
    }
  }

  Future<void> removeMember(String memberIdToRemove) async {
    if (!amIAdmin && memberIdToRemove != currentUserId) return;
    if (groupDetails?.adminIds.length == 1 && groupDetails?.adminIds.first == memberIdToRemove) {
      _setError("The last admin cannot be removed.");
      notifyListeners();
      return;
    }
    try {
      await _removeMemberFromGroupUseCase(groupId: groupId, memberIdToRemove: memberIdToRemove);
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
      final updatedGroup = groupDetails!.copyWith(name: trimmedName);
      await _updateGroupChatDetailsUseCase(groupChatEntity: updatedGroup);
    } catch (e, s) {
      AppLogger.error("Error updating group name for $groupId", e, s);
      _setError("Could not update group name.");
      notifyListeners();
    }
  }

  Future<void> leaveOrDeleteGroup() async {
    if (groupDetails == null || currentUserId.isEmpty) return;
    final bool isLastMember = groupDetails!.memberIds.length == 1 && groupDetails!.memberIds.first == currentUserId;
    if (isLastMember) {
      try {
        await _deleteGroupUseCase(groupId: groupId);
      } catch (e) {
        _setError("Failed to delete the group.");
        notifyListeners();
      }
    } else {
      try {
        await _removeMemberFromGroupUseCase(groupId: groupId, memberIdToRemove: currentUserId);
      } catch (e) {
        _setError("Failed to leave the group.");
        notifyListeners();
      }
    }
  }

  Future<void> startGroupChallenge(String challengeId) async {
    final inviterId = _authProvider.currentUserId;
    if (inviterId == null || _groupDetails == null) return;
    final params = CreateInviteParams(
      inviterId: inviterId,
      challengeId: challengeId,
      context: InviteContext.group,
      contextId: _groupDetails!.id,
      recipientIds: _groupDetails!.memberIds,
    );
    try {
      await _createChallengeInviteUseCase(params);
    } catch (e) {
      AppLogger.error("Fehler beim Erstellen der Challenge-Einladung: $e");
    }
  }

  /// Akzeptiert eine Challenge-Einladung im Namen des aktuellen Nutzers.
  Future<void> acceptChallengeInvite(InviteEntity invite) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _setError("Fehler: Du bist nicht eingeloggt.");
      notifyListeners();
      return;
    }

    try {
      AppLogger.info("Versuche, Challenge ${invite.targetId} zu akzeptieren...");
      final challenge = await _getChallengeByIdUseCase(invite.targetId);

      if (challenge == null) {
        AppLogger.error("Challenge mit ID ${invite.targetId} nicht gefunden.");
        _setError("Fehler: Diese Challenge konnte nicht gefunden werden.");
        notifyListeners();
        return;
      }

      AppLogger.info("Challenge '${challenge.title}' gefunden. Starte Akzeptanz-Prozess...");

      // KORREKTUR HIER:
      // Anstatt 'inviteId' wird das gesamte 'invite'-Objekt erwartet.
      final params = AcceptInviteParams(
        invite: invite,
        userId: userId,
        challenge: challenge,
      );
      await _acceptChallengeInviteUseCase(params);

      AppLogger.info("Challenge-Einladung erfolgreich akzeptiert.");
    } catch (e) {
      AppLogger.error("Unerwarteter Fehler beim Akzeptieren der Einladung: $e");
      _setError("Ein unerwarteter Fehler ist aufgetreten.");
      notifyListeners();
    }
  }

  /// Lehnt eine Challenge-Einladung im Namen des aktuellen Nutzers ab.
  Future<void> declineChallengeInvite(InviteEntity invite) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) return;
    final params = DeclineInviteParams(inviteId: invite.id, userId: userId);
    await _declineChallengeInviteUseCase(params);
  }

  // --- Dispose-Logik ---
  bool _isValidState = true;

  @override
  void dispose() {
    _isValidState = false;
    _groupDetailsSubscription?.cancel();
    _chatItemsSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    super.dispose();
  }
}