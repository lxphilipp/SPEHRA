// lib/features/chat/presentation/providers/group_chat_provider.dart

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_sdg/features/challenges/domain/usecases/get_challenge_by_id_usecase.dart';
import 'package:rxdart/rxdart.dart';

// Entities
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/domain/entities/group_challenge_progress_entity.dart';
import '../../../challenges/domain/usecases/watch_group_progress_by_context_id_usecase.dart';
import '../../../invites/domain/entities/invite_entity.dart';
import '../../../invites/domain/usecases/accept_challenge_invite_usecase.dart';
import '../../../invites/domain/usecases/create_challenge_invite_usecase.dart';
import '../../../invites/domain/usecases/decline_challenge_invite_usecase.dart';
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

/// Manages the state and business logic for a specific group chat.
///
/// This provider handles fetching group details, messages, member information,
/// active challenges, and challenge invites. It also provides methods for
/// sending messages, managing group members, updating group details,
/// and interacting with group challenges.
class GroupChatProvider with ChangeNotifier {
  // --- UseCases and Dependencies ---

  /// Use case to watch group chat details by its ID.
  final WatchGroupChatByIdUseCase _watchGroupChatByIdUseCase;
  /// Use case to send a message.
  final SendMessageUseCase _sendMessageUseCase;
  /// Use case to upload a chat image.
  final UploadChatImageUseCase _uploadChatImageUseCase;
  /// Use case to get a stream of chat users by their IDs.
  final GetChatUsersStreamByIdsUseCase _getChatUsersStreamByIdsUseCase;
  /// Provider for authentication-related information.
  final AuthenticationProvider _authProvider;
  /// Use case to update group chat details.
  final UpdateGroupChatDetailsUseCase _updateGroupChatDetailsUseCase;
  /// Use case to add members to a group.
  final AddMembersToGroupUseCase _addMembersToGroupUseCase;
  /// Use case to remove a member from a group.
  final RemoveMemberFromGroupUseCase _removeMemberFromGroupUseCase;
  /// Use case to delete a group.
  final DeleteGroupUseCase _deleteGroupUseCase;
  /// Use case to get combined chat items (messages and invites).
  final GetCombinedChatItemsUseCase _getCombinedChatItemsUseCase;
  /// Use case to get challenge details by its ID.
  final GetChallengeByIdUseCase _getChallengeByIdUseCase;
  /// Use case to accept a challenge invite.
  final AcceptChallengeInviteUseCase _acceptChallengeInviteUseCase;
  /// Use case to decline a challenge invite.
  final DeclineChallengeInviteUseCase _declineChallengeInviteUseCase;
  /// Use case to create a challenge invite.
  final CreateChallengeInviteUseCase _createChallengeInviteUseCase;
  /// Use case to watch group challenge progress by context ID.
  final WatchGroupProgressByContextIdUseCase _watchGroupProgressByContextIdUseCase;

  /// The ID of the group chat this provider is managing.
  final String groupId;

  /// Creates an instance of [GroupChatProvider].
  ///
  /// Requires various use cases and providers to function.
  ///
  /// [groupId] The ID of the group chat.
  /// [watchGroupChatByIdUseCase] Use case to watch group chat details.
  /// [sendMessageUseCase] Use case to send messages.
  /// [uploadChatImageUseCase] Use case to upload chat images.
  /// [getChatUsersStreamByIdsUseCase] Use case to get chat user details.
  /// [updateGroupChatDetailsUseCase] Use case to update group details.
  /// [addMembersToGroupUseCase] Use case to add members to the group.
  /// [removeMemberFromGroupUseCase] Use case to remove members from the group.
  /// [authProvider] Authentication provider for user information.
  /// [deleteGroupUseCase] Use case to delete the group.
  /// [createChallengeInviteUseCase] Use case to create challenge invites.
  /// [getChallengeByIdUseCase] Use case to fetch challenge details.
  /// [acceptChallengeInviteUseCase] Use case to accept challenge invites.
  /// [declineChallengeInviteUseCase] Use case to decline challenge invites.
  /// [getCombinedChatItemsUseCase] Use case to get combined chat items.
  /// [watchGroupProgressByContextIdUseCase] Use case to watch group challenge progress.
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
    required WatchGroupProgressByContextIdUseCase watchGroupProgressByContextIdUseCase,
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
        _watchGroupProgressByContextIdUseCase = watchGroupProgressByContextIdUseCase {
    AppLogger.debug("GroupChatProvider for groupId: $groupId initialized.");
    _subscribeToGroupDetails();
  }

  // --- Provider State ---

  /// The details of the current group chat. Null if not loaded or not found.
  GroupChatEntity? _groupDetails;
  /// The list of chat items, which can include messages and invites.
  List<dynamic> _chatItems = [];
  /// A map of member IDs to their [ChatUserEntity] details.
  Map<String, ChatUserEntity> _memberDetailsMap = {};
  /// True if initial data is being loaded, false otherwise.
  bool _isLoadingInitialData = true;
  /// True if a message is currently being sent, false otherwise.
  bool _isSendingMessage = false;
  /// Stores any error message that occurred. Null if no error.
  String? _error;
  /// The image file selected for preview before sending.
  File? _imagePreview;
  /// List of active group challenge progress entities for this group.
  List<GroupChallengeProgressEntity> _activeChallenges = [];
  /// Cache for challenge details related to invites, keyed by challenge ID.
  final Map<String, ChallengeEntity> _challengeDetailsForInvites = {};
  /// Cache for challenge details related to active challenges, keyed by challenge ID.
  final Map<String, ChallengeEntity> _challengeDetailsForActiveChallenges = {};


  // --- Stream Subscriptions ---

  /// Subscription to the group details stream.
  StreamSubscription<GroupChatEntity?>? _groupDetailsSubscription;
  /// Subscription to the member details stream.
  StreamSubscription<List<ChatUserEntity>>? _memberDetailsSubscription;
  /// Subscription to the combined chat items stream.
  StreamSubscription? _chatItemsSubscription;
  /// Subscription to the group challenge progress stream.
  StreamSubscription? _challengeProgressSubscription;

  // --- Getters ---

  /// Returns the current group chat details.
  GroupChatEntity? get groupDetails => _groupDetails;
  /// Returns the list of chat items (messages, invites).
  List<dynamic> get chatItems => _chatItems;
  /// Returns a map of member IDs to their user details.
  Map<String, ChatUserEntity> get memberDetailsMap => _memberDetailsMap;
  /// Returns true if initial data is loading.
  bool get isLoadingInitialData => _isLoadingInitialData;
  /// Returns true if a message is currently being sent.
  bool get isSendingMessage => _isSendingMessage;
  /// Returns the current error message, if any.
  String? get error => _error;
  /// Returns the image file selected for preview.
  File? get imagePreview => _imagePreview;
  /// Returns the ID of the current authenticated user.
  String get currentUserId => _authProvider.currentUserId ?? '';
  /// Returns true if the current user is an admin of the group.
  bool get amIAdmin => groupDetails?.adminIds.contains(currentUserId) ?? false;
  /// Returns the list of active challenges for the group.
  List<GroupChallengeProgressEntity> get activeChallenges => _activeChallenges;
  /// Returns the cached [ChallengeEntity] for a given invite's target challenge ID.
  ChallengeEntity? getChallengeDetailsForInvite(String challengeId) => _challengeDetailsForInvites[challengeId];
  /// Returns the cached [ChallengeEntity] for a given active challenge ID.
  ChallengeEntity? getChallengeDetailsForActiveChallenge(String challengeId) => _challengeDetailsForActiveChallenges[challengeId];


  // --- Core Logic & Subscriptions ---

  /// Subscribes to the combined stream of chat items (messages and invites).
  ///
  /// Filters out [GroupChallengeProgressEntity] items as they are handled separately.
  /// Fetches challenge details for any new invites.
  void _subscribeToChatItems() {
    _chatItemsSubscription?.cancel();
    _chatItemsSubscription = _getCombinedChatItemsUseCase(groupId).listen((items) {
      if (!_isValidState) return;
      // Filter out GroupChallengeProgressEntity as they are handled by _subscribeToChallengeProgress
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

  /// Fetches and caches challenge details for invite items if not already present.
  ///
  /// Iterates through [InviteEntity] items and fetches their corresponding
  /// [ChallengeEntity] if not already in [_challengeDetailsForInvites].
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

  /// Subscribes to changes in the group details.
  ///
  /// Handles initial data loading state, updates group details,
  /// and triggers subscriptions to member details and chat items if needed.
  /// Also initiates subscription to challenge progress.
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

        // Start subscription for challenge progress if not already started
        if (_challengeProgressSubscription == null) {
          _subscribeToChallengeProgress();
        }

        if (!hasDetailsChanged) { // If only member list might have changed or nothing
          if (_isLoadingInitialData) { // Still, ensure loading state is turned off
            _isLoadingInitialData = false;
            notifyListeners();
          }
          // If details haven't changed but members have, _subscribeToMemberDetails will handle it
          if (haveMembersChanged && newDetails.memberIds.isNotEmpty) {
             _subscribeToMemberDetails(newDetails.memberIds);
          } else if (haveMembersChanged && newDetails.memberIds.isEmpty) {
            _memberDetailsSubscription?.cancel();
            _memberDetailsMap = {};
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

        // Subscribe to chat items only once after group details are loaded
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

  /// Subscribes to the stream of active group challenge progress.
  ///
  /// Updates [_activeChallenges] and fetches details for any new challenges.
  void _subscribeToChallengeProgress() {
    _challengeProgressSubscription?.cancel();
    _challengeProgressSubscription = _watchGroupProgressByContextIdUseCase(groupId)
        .asStream() // Convert Future<Stream> to Stream<Stream>
        .switchMap((stream) => stream) // Switch to the latest inner stream
        .listen((challenges) {
      if (!_isValidState) return;
      if (!const ListEquality().equals(_activeChallenges, challenges)) {
        _activeChallenges = challenges;
        _fetchChallengeDetailsForActiveChallenges(challenges);
        notifyListeners();
      }
    }, onError: (e) {
      if (!_isValidState) return;
      AppLogger.error("Error in group challenge progress stream for group $groupId: $e");
      // Optionally set an error state or log, but typically this is a background process.
    });
  }


  /// Subscribes to the stream of member details for the given list of member IDs.
  ///
  /// Updates [_memberDetailsMap] with the latest user information.
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
        // Optionally set an error for member loading issues.
      },
    );
  }

  /// Fetches and caches [ChallengeEntity] details for active challenges if not already present.
  ///
  /// Iterates through [GroupChallengeProgressEntity] items and fetches their
  /// corresponding [ChallengeEntity] if not already in [_challengeDetailsForActiveChallenges].
  void _fetchChallengeDetailsForActiveChallenges(List<GroupChallengeProgressEntity> challenges) {
    for (var progress in challenges) {
      if (!_challengeDetailsForActiveChallenges.containsKey(progress.challengeId)) {
        _getChallengeByIdUseCase(progress.challengeId).then((challenge) {
          if (challenge != null && _isValidState) {
            _challengeDetailsForActiveChallenges[progress.challengeId] = challenge;
            notifyListeners();
          }
        });
      }
    }
  }

  /// Handles the scenario where the group is not found or has been deleted.
  ///
  /// Sets an error message, clears group-related data, and cancels subscriptions.
  void _handleGroupNotFoundOrDeleted(String errorMessage) {
    _error = errorMessage;
    _groupDetails = null;
    _chatItems = [];
    _memberDetailsMap = {};
    _activeChallenges = [];
    _challengeDetailsForActiveChallenges.clear();
    _challengeDetailsForInvites.clear();
    _isLoadingInitialData = false;

    _chatItemsSubscription?.cancel();
    _chatItemsSubscription = null;
    _memberDetailsSubscription?.cancel();
    _memberDetailsSubscription = null;
    _challengeProgressSubscription?.cancel();
    _challengeProgressSubscription = null;
    // Keep _groupDetailsSubscription active to potentially recover if group reappears or error was transient.
    // However, if it's a permanent deletion, this provider instance should ideally be disposed and recreated.
    notifyListeners();
  }

  /// Sets the error message if it has changed.
  void _setError(String? message) {
    if (_error != message) {
      _error = message;
      // notifyListeners() should be called by the public method that calls _setError
    }
  }

  // --- Public Actions ---

  /// Forces a reload of all group data by re-subscribing to group details.
  ///
  /// This cancels existing subscriptions and re-initializes the data fetching process.
  void forceReloadData() {
    AppLogger.debug("Force reloading data for group $groupId");
    // Cancel all subscriptions
    _groupDetailsSubscription?.cancel();
    _chatItemsSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    _challengeProgressSubscription?.cancel();

    // Clear existing data
    _groupDetails = null;
    _chatItems = [];
    _memberDetailsMap = {};
    _activeChallenges = [];
    _challengeDetailsForInvites.clear();
    _challengeDetailsForActiveChallenges.clear();
    _imagePreview = null; // Reset image preview as well

    // Reset subscription references
    _groupDetailsSubscription = null;
    _chatItemsSubscription = null;
    _memberDetailsSubscription = null;
    _challengeProgressSubscription = null;


    // Re-initiate the primary subscription
    _subscribeToGroupDetails();
    // No need to call notifyListeners() here as _subscribeToGroupDetails will do it.
  }

  /// Sends a text message to the group.
  ///
  /// [text] The content of the message.
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

  /// Sets an image file for preview before sending.
  ///
  /// [imageFile] The image file to preview. Set to null to clear preview.
  void setImageForPreview(File? imageFile) {
    _imagePreview = imageFile;
    notifyListeners();
  }

  /// Sends the selected image to the group.
  ///
  /// The image must be set via [setImageForPreview] first.
  Future<void> sendSelectedImage() async {
    if (_imagePreview == null || currentUserId.isEmpty || _groupDetails == null) return;
    _isSendingMessage = true;
    _setError(null);
    File imageToSend = _imagePreview!;
    setImageForPreview(null); // Clear preview immediately
    // notifyListeners() is called by setImageForPreview

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

  /// Retrieves the [ChatUserEntity] for a given user ID.
  ///
  /// [userId] The ID of the user to retrieve details for.
  /// Returns the [ChatUserEntity] or null if not found.
  ChatUserEntity? getMemberDetail(String userId) {
    return _memberDetailsMap[userId];
  }

  /// Adds a list of users to the group.
  ///
  /// Only an admin can perform this action.
  /// [userIdsToAdd] A list of user IDs to add to the group.
  Future<void> addMembers(List<String> userIdsToAdd) async {
    if (!amIAdmin) {
      _setError("Only admins can add members.");
      notifyListeners();
      return;
    }
    if (userIdsToAdd.isEmpty) return;
    _setError(null); // Clear previous error

    try {
      await _addMembersToGroupUseCase(groupId: groupId, memberIdsToAdd: userIdsToAdd);
      // Group details will update via stream, no need to manually update here.
    } catch (e, s) {
      AppLogger.error("Error adding members to group $groupId", e, s);
      _setError("Could not add members.");
      notifyListeners();
    }
  }

  /// Removes a member from the group.
  ///
  /// Admins can remove any member. Non-admins can only remove themselves (leave group).
  /// The last admin cannot be removed.
  /// [memberIdToRemove] The ID of the member to remove.
  Future<void> removeMember(String memberIdToRemove) async {
    if (!amIAdmin && memberIdToRemove != currentUserId) {
       _setError("You do not have permission to remove this member.");
       notifyListeners();
      return;
    }
    if (groupDetails?.adminIds.length == 1 && groupDetails?.adminIds.first == memberIdToRemove && groupDetails!.memberIds.length > 1) {
      _setError("The last admin cannot be removed if other members still exist. Assign another admin first or remove other members.");
      notifyListeners();
      return;
    }
     _setError(null); // Clear previous error

    try {
      await _removeMemberFromGroupUseCase(groupId: groupId, memberIdToRemove: memberIdToRemove);
      // If current user leaves, this provider instance might become invalid for further use by that user.
      // Group details will update via stream.
    } catch (e, s) {
      AppLogger.error("Error removing member from group $groupId", e, s);
      _setError("Could not remove member.");
      notifyListeners();
    }
  }

  /// Updates the name of the group.
  ///
  /// Only an admin can perform this action.
  /// [newName] The new name for the group.
  Future<void> updateGroupName(String newName) async {
    if (!amIAdmin || groupDetails == null) {
      _setError("Only admins can update group name.");
      notifyListeners();
      return;
    }
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == groupDetails!.name) return;
     _setError(null); // Clear previous error

    try {
      // Optimistic update:
      // final oldName = groupDetails!.name;
      // _groupDetails = groupDetails!.copyWith(name: trimmedName);
      // notifyListeners();

      final updatedGroup = groupDetails!.copyWith(name: trimmedName);
      await _updateGroupChatDetailsUseCase(groupChatEntity: updatedGroup);
      // Group details will update via stream. If optimistic update, revert on error.
    } catch (e, s) {
      AppLogger.error("Error updating group name for $groupId", e, s);
      _setError("Could not update group name.");
      // if optimistic: _groupDetails = groupDetails!.copyWith(name: oldName);
      notifyListeners();
    }
  }

  /// Allows the current user to leave the group, or delete it if they are the last member.
  Future<void> leaveOrDeleteGroup() async {
    if (groupDetails == null || currentUserId.isEmpty) return;
    _setError(null);

    final bool isLastMember = groupDetails!.memberIds.length == 1 && groupDetails!.memberIds.first == currentUserId;
    if (isLastMember) {
      try {
        await _deleteGroupUseCase(groupId: groupId);
        // Group will be removed, _handleGroupNotFoundOrDeleted should be triggered by stream
      } catch (e,s) {
        AppLogger.error("Error deleting group $groupId", e, s);
        _setError("Failed to delete the group.");
        notifyListeners();
      }
    } else {
      try {
        await _removeMemberFromGroupUseCase(groupId: groupId, memberIdToRemove: currentUserId);
        // User has left, stream will update.
      } catch (e,s) {
         AppLogger.error("Error leaving group $groupId", e, s);
        _setError("Failed to leave the group.");
        notifyListeners();
      }
    }
  }

  /// Starts a new group challenge by creating invites for all group members.
  ///
  /// [challengeId] The ID of the challenge to start.
  Future<void> startGroupChallenge(String challengeId) async {
    final inviterId = _authProvider.currentUserId;
    if (inviterId == null || _groupDetails == null) {
       _setError("You must be logged in and in a group to start a challenge.");
       notifyListeners();
      return;
    }
    if (_groupDetails!.memberIds.isEmpty) {
      _setError("Cannot start a challenge in an empty group.");
      notifyListeners();
      return;
    }
    _setError(null);

    final params = CreateInviteParams(
      inviterId: inviterId,
      challengeId: challengeId,
      context: InviteContext.group,
      contextId: _groupDetails!.id,
      recipientIds: _groupDetails!.memberIds, // Send to all members
    );
    try {
      await _createChallengeInviteUseCase(params);
      // Invites will appear in the chat via _getCombinedChatItemsUseCase stream
    } catch (e) {
      AppLogger.error("Fehler beim Erstellen der Challenge-Einladung: $e");
      _setError("Failed to start group challenge.");
      notifyListeners();
    }
  }

  /// Accepts a challenge invite on behalf of the current user.
  ///
  /// [invite] The [InviteEntity] to accept.
  Future<void> acceptChallengeInvite(InviteEntity invite) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
      _setError("Fehler: Du bist nicht eingeloggt.");
      notifyListeners();
      return;
    }
    _setError(null);

    try {
      AppLogger.info("Attempting to accept Challenge ${invite.targetId} for group $groupId...");
      final challenge = await _getChallengeByIdUseCase(invite.targetId);

      if (challenge == null) {
        AppLogger.error("Challenge with ID ${invite.targetId} not found for acceptance.");
        _setError("Fehler: Diese Challenge konnte nicht gefunden werden.");
        notifyListeners();
        return;
      }

      AppLogger.info("Challenge '${challenge.title}' found. Starting acceptance process...");

      final params = AcceptInviteParams(
        invite: invite, // Pass the whole invite object
        userId: userId,
        challenge: challenge,
      );
      await _acceptChallengeInviteUseCase(params);
      // Invite state should update via chat items stream or challenge progress stream
      AppLogger.info("Challenge invite accepted successfully for group $groupId.");
    } catch (e,s) {
      AppLogger.error("Unexpected error accepting invite for group $groupId: $e", e,s);
      _setError("Ein unerwarteter Fehler ist aufgetreten beim Akzeptieren.");
      notifyListeners();
    }
  }

  /// Declines a challenge invite on behalf of the current user.
  ///
  /// [invite] The [InviteEntity] to decline.
  Future<void> declineChallengeInvite(InviteEntity invite) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) {
       _setError("You must be logged in to decline an invite.");
       notifyListeners();
      return;
    }
    _setError(null);
    try {
      final params = DeclineInviteParams(inviteId: invite.id, userId: userId);
      await _declineChallengeInviteUseCase(params);
      // Invite state should update via chat items stream
    } catch (e,s) {
       AppLogger.error("Error declining challenge invite for group $groupId: $e",e,s);
       _setError("Failed to decline challenge invite.");
       notifyListeners();
    }
  }

  // --- Dispose Logic ---

  /// Flag to check if the provider is still in a valid state (not disposed).
  bool _isValidState = true;

  @override
  void dispose() {
    AppLogger.debug("Disposing GroupChatProvider for groupId: $groupId");
    _isValidState = false; // Mark as disposed first
    _groupDetailsSubscription?.cancel();
    _chatItemsSubscription?.cancel();
    _memberDetailsSubscription?.cancel();
    _challengeProgressSubscription?.cancel();
    super.dispose();
  }
}
