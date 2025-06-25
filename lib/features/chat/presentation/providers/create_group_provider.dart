// lib/features/chat/presentation/providers/create_group_provider.dart

import 'package:flutter/material.dart';

// Core
import '../../../../core/utils/app_logger.dart';

// Dependencies: Providers and Entities
import 'group_chat_list_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_user_entity.dart';

/// Manages the state for the group creation screen/flow.
///
/// This provider handles:
/// - The group name input.
/// - The list of selected members.
/// - The logic for submitting the new group to the `GroupChatListProvider`.
/// It is designed to be updated by a `ChangeNotifierProxyProvider2`.
class CreateGroupProvider with ChangeNotifier {
  // --- Internal Provider References ---
  // These will be kept up-to-date by the `updateDependencies` method.
  late GroupChatListProvider _groupChatListProvider;
  late AuthenticationProvider _authProvider;

  // --- State ---
  String _groupName = '';
  List<ChatUserEntity> _selectedMembers = [];
  bool _isCreatingGroup = false;
  String? _error;
  bool _isInitialized = false;

  /// The constructor is now simple and has no parameters.
  CreateGroupProvider() {
    AppLogger.debug("CreateGroupProvider: Instance created.");
  }

  // --- Getters for the UI ---
  String get groupName => _groupName;
  List<ChatUserEntity> get selectedMembers => List.unmodifiable(_selectedMembers);
  bool get isCreatingGroup => _isCreatingGroup;
  String? get error => _error;

  // --- Dependency Update Method ---

  /// The gateway for receiving updates from dependency providers.
  void updateDependencies(
      AuthenticationProvider auth,
      GroupChatListProvider groupChatList,
      ) {
    // 1. Update internal references
    _authProvider = auth;
    _groupChatListProvider = groupChatList;

    // 2. Initialize the creator as the first member, but only once.
    if (!_isInitialized && auth.isLoggedIn) {
      _initializeCreatorAsMember();
      _isInitialized = true;
    }
  }

  // --- Private Initialization ---
  void _initializeCreatorAsMember() {
    final authUser = _authProvider.currentUser;
    if (authUser != null) {
      final creatorAsChatUser = ChatUserEntity(
        id: authUser.id,
        name: authUser.name ?? "You", // Fallback name
        imageUrl: null, // UserEntity doesn't have an image URL
      );
      // Ensure the creator isn't already in the list for any reason
      if (!_selectedMembers.any((m) => m.id == creatorAsChatUser.id)) {
        _selectedMembers = [creatorAsChatUser];
        AppLogger.debug("CreateGroupProvider: Initialized with creator: ${creatorAsChatUser.name}");
      }
    } else {
      AppLogger.warning("CreateGroupProvider: Cannot initialize creator, currentUser is null.");
    }
  }

  // --- Public Methods for State Changes ---

  /// Updates the group name from a text field. Should be called from `onChanged`.
  void setGroupName(String name) {
    final trimmedName = name.trim();
    if (_groupName == trimmedName) return;
    _groupName = trimmedName;
  }

  /// Updates the list of selected members, ensuring the creator is always included.
  void setSelectedMembers(List<ChatUserEntity> membersFromSearch) {
    final currentAuthUser = _authProvider.currentUser;
    Set<ChatUserEntity> newSelectionSet = Set.from(membersFromSearch);

    if (currentAuthUser != null) {
      final creatorIsIncluded = newSelectionSet.any((m) => m.id == currentAuthUser.id);
      if (!creatorIsIncluded) {
        // Add the creator's info from the reliable auth provider.
        newSelectionSet.add(ChatUserEntity(
          id: currentAuthUser.id,
          name: currentAuthUser.name ?? "You",
          imageUrl: null, // No image from UserEntity
        ));
        AppLogger.debug("CreateGroupProvider: Creator was (re-)added to the selection.");
      }
    }
    _selectedMembers = newSelectionSet.toList();
    _selectedMembers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    AppLogger.debug("CreateGroupProvider: Selected members updated. Count: ${_selectedMembers.length}");
    notifyListeners();
  }

  /// Removes a member from the selected list. The creator cannot be removed.
  void removeMember(ChatUserEntity member) {
    final currentUserId = _authProvider.currentUserId;
    if (member.id == currentUserId) {
      _error = "The group creator cannot be removed.";
      AppLogger.info("CreateGroupProvider: Attempted to remove the creator.");
      notifyListeners();
      return;
    }
    _selectedMembers.removeWhere((m) => m.id == member.id);
    notifyListeners();
  }

  /// Submits the request to create the new group.
  /// Returns the new group's ID on success, or null on failure.
  Future<String?> submitCreateGroup() async {
    if (_groupName.trim().isEmpty) {
      _error = "Please enter a group name.";
      notifyListeners();
      return null;
    }
    final currentUserId = _authProvider.currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      _error = "Error: Not logged in.";
      notifyListeners();
      return null;
    }
    if (_selectedMembers.isEmpty || !_selectedMembers.any((m) => m.id == currentUserId)) {
      _error = "The creator must be a member of the group.";
      notifyListeners();
      return null;
    }

    _isCreatingGroup = true;
    _error = null;
    notifyListeners();

    List<String> memberIds = _selectedMembers.map((m) => m.id).toList();
    List<String> adminIds = [currentUserId]; // Creator is the first admin

    try {
      final groupId = await _groupChatListProvider.createNewGroup(
        name: _groupName.trim(),
        memberIds: memberIds,
        adminIds: adminIds,
        imageUrl: null, // Group image upload is not implemented in this version
        initialTextMessage: "Welcome to the group '$_groupName'!",
      );

      if (groupId != null) {
        _resetStateAfterSuccess();
        return groupId;
      } else {
        _error = _groupChatListProvider.error ?? "Could not create group.";
      }
    } catch (e) {
      _error = "An unexpected error occurred.";
      AppLogger.error("CreateGroup Error", e);
    } finally {
      _isCreatingGroup = false;
      notifyListeners();
    }
    return null;
  }

  /// Resets the local state after a group has been successfully created.
  void _resetStateAfterSuccess() {
    _groupName = '';
    _selectedMembers = [];
    _isInitialized = false; // Allow re-initialization if the screen is visited again
    _initializeCreatorAsMember();
  }
}