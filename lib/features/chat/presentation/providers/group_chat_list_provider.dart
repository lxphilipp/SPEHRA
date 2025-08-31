// lib/features/chat/presentation/providers/group_chat_list_provider.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

// Domain & Entities
import '../../domain/entities/group_chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_group_chats_stream_usecase.dart';
import '../../domain/usecases/create_group_chat_usecase.dart';

// Auth Feature
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

/// Manages the state for the list of group chats.
///
/// This provider handles fetching, sorting, and creating group chats.
/// It listens to authentication changes to update the chat list accordingly.
class GroupChatListProvider with ChangeNotifier {
  // --- UseCases ---
  final GetGroupChatsStreamUseCase _getGroupChatsStreamUseCase;
  final CreateGroupChatUseCase _createGroupChatUseCase;

  // --- State ---
  List<GroupChatEntity> _groupChats = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  String _sortCriteria = 'lastMessageTime'; // Default sort criteria
  bool _isSortAscending = false; // false = descending (newest first)

  // --- Stream Subscriptions ---
  StreamSubscription<List<GroupChatEntity>>? _groupChatsSubscription;

  /// Creates a [GroupChatListProvider].
  ///
  /// Requires instances of [GetGroupChatsStreamUseCase] and [CreateGroupChatUseCase].
  GroupChatListProvider({
    required GetGroupChatsStreamUseCase getGroupChatsStreamUseCase,
    required CreateGroupChatUseCase createGroupChatUseCase,
  })  : _getGroupChatsStreamUseCase = getGroupChatsStreamUseCase,
        _createGroupChatUseCase = createGroupChatUseCase {
    AppLogger.debug("GroupChatListProvider: Instance created.");
  }

  // --- Getters for the UI ---

  /// Whether the group chats are currently being loaded.
  bool get isLoading => _isLoading;

  /// The last error message, if any.
  String? get error => _error;

  /// The list of group chats, sorted according to [_sortCriteria] and [_isSortAscending].
  List<GroupChatEntity> get sortedGroupChats {
    List<GroupChatEntity> sorted = List.from(_groupChats);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortCriteria) {
        case 'lastMessageTime':
        default:
          // Handle null lastMessageTime by treating them as very old.
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          comparison = aTime.compareTo(bTime);
          break;
      }
      return _isSortAscending ? comparison : -comparison; // Apply ascending/descending
    });
    return sorted;
  }

  /// The raw, unsorted list of group chats.
  List<GroupChatEntity> get groupChats => _groupChats;

  /// Sets the sorting criteria and direction for the group chat list.
  ///
  /// [newSortValue] is a string in the format "criteria_direction" (e.g., "lastMessageTime_desc").
  /// If direction is not specified, it defaults to descending.
  void setSortCriteria(String newSortValue) {
    final parts = newSortValue.split('_');
    final newCriteria = parts[0];
    // Default to 'desc' (which means _isSortAscending = false) if not specified
    final newDirectionIsAsc = (parts.length > 1 && parts[1] == 'asc');

    if (_sortCriteria != newCriteria || _isSortAscending != newDirectionIsAsc) {
      _sortCriteria = newCriteria;
      _isSortAscending = newDirectionIsAsc;
      AppLogger.debug("GroupChatListProvider: Sort criteria updated - Criteria: $_sortCriteria, Ascending: $_isSortAscending");
      notifyListeners();
    }
  }

  /// Updates dependencies, particularly the current user ID from [AuthenticationProvider].
  ///
  /// If the user ID changes, it re-subscribes to the group chats stream for the new user
  /// or resets the state if the user logs out.
  void updateDependencies(AuthenticationProvider authProvider) {
    final newUserId = authProvider.currentUserId;

    if (newUserId != _currentUserId) {
      _currentUserId = newUserId;
      AppLogger.debug("GroupChatListProvider: Auth dependency updated. New User ID: $newUserId");

      if (_currentUserId != null) {
        _subscribeToGroupChats(_currentUserId!);
      } else {
        _resetState(); // User logged out
      }
    }
  }

  /// Subscribes to the stream of group chats for the given [userId].
  ///
  /// Manages loading state and error handling for the stream.
  void _subscribeToGroupChats(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _groupChatsSubscription?.cancel(); // Cancel any existing subscription
    _groupChatsSubscription = _getGroupChatsStreamUseCase(currentUserId: userId).listen(
          (groups) {
        // Only update and notify if the list content has actually changed.
        if (!const ListEquality().equals(_groupChats, groups)) {
          _groupChats = groups;
        }
        _isLoading = false;
        _error = null;
        AppLogger.info("GroupChatListProvider: Received ${groups.length} group chats.");
        notifyListeners();
      },
      onError: (e, stackTrace) {
        AppLogger.error("GroupChatListProvider: Error loading group chats stream", e, stackTrace);
        _groupChats = []; // Clear chats on error
        _isLoading = false;
        _error = "Error loading group chats.";
        notifyListeners();
      },
    );
  }

  /// Resets the provider's state, clearing group chats and canceling subscriptions.
  /// Typically called when the user logs out.
  void _resetState() {
    AppLogger.debug("GroupChatListProvider: User logged out, resetting state.");
    _groupChats = [];
    _isLoading = false;
    _error = null;
    _groupChatsSubscription?.cancel();
    _groupChatsSubscription = null;
    notifyListeners();
  }

  /// Forces a reload of the group chats if a user is currently logged in.
  /// This will re-subscribe to the group chats stream.
  void forceReloadGroupChats() {
    final userId = _currentUserId;
    if (userId != null) {
      AppLogger.info("GroupChatListProvider: Force reloading group chats for user $userId.");
      _subscribeToGroupChats(userId);
    } else {
      AppLogger.warning("GroupChatListProvider: Cannot force reload, no current user.");
    }
  }

  /// Creates a new group chat.
  ///
  /// Requires [name], [memberIds], and [adminIds].
  /// Optionally takes [imageUrl] and an [initialTextMessage].
  /// Returns the ID of the newly created group, or null if creation fails.
  Future<String?> createNewGroup({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    String? imageUrl,
    String? initialTextMessage,
  }) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      _error = "Not logged in, cannot create a group.";
      AppLogger.warning("GroupChatListProvider: createNewGroup called without a logged-in user.");
      notifyListeners();
      return null;
    }

    // Ensure the current user is part of members and admins
    if (!memberIds.contains(userId)) memberIds.add(userId);
    if (!adminIds.contains(userId)) adminIds.add(userId);

    _error = null; // Clear previous errors

    MessageEntity? initialMessage;
    if (initialTextMessage != null && initialTextMessage.isNotEmpty) {
      initialMessage = MessageEntity(
        id: '', // ID will be generated by the backend
        fromId: userId,
        toId: '', // For group chats, toId might be group's ID, handled by backend
        msg: initialTextMessage,
        type: MessageType.text,
        createdAt: DateTime.now(),
      );
    }

    try {
      AppLogger.debug("GroupChatListProvider: Attempting to create new group: $name with members: $memberIds");
      final groupId = await _createGroupChatUseCase(
        name: name,
        memberIds: memberIds,
        adminIds: adminIds,
        currentUserId: userId,
        imageUrl: imageUrl,
        initialMessage: initialMessage,
      );

      if (groupId == null) {
        _error = "Could not create group. The operation returned no ID.";
        AppLogger.warning("GroupChatListProvider: createNewGroup - _createGroupChatUseCase returned null for group: $name");
      } else {
        AppLogger.info("GroupChatListProvider: Group $groupId created successfully: $name.");
        _error = null; // Ensure error is cleared on success
        // Optionally, could force a reload here or rely on stream updates
      }
      // Notify listeners if there was an error or to reflect potential optimistic updates
      // (though currently, we rely on the stream for updates post-creation)
      if (_error != null) notifyListeners();
      return groupId;
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatListProvider: Error creating new group '$name'", e, stackTrace);
      _error = "An error occurred while creating the group. Please try again.";
      notifyListeners();
      return null;
    }
  }

  /// Cleans up resources when the provider is disposed.
  ///
  /// Cancels any active stream subscriptions.
  @override
  void dispose() {
    AppLogger.debug("GroupChatListProvider: Disposing...");
    _groupChatsSubscription?.cancel();
    super.dispose();
  }
}
