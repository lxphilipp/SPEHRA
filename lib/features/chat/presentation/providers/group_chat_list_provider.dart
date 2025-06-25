// lib/features/chat/presentation/providers/group_chat_list_provider.dart

import 'dart:async';

// Domain & Entities
import 'package:flutter/cupertino.dart';

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
/// This provider is responsible for:
/// - Subscribing to the user's group chats based on their auth state.
/// - Providing methods to create new group chats.
/// It is designed to be updated by a `ChangeNotifierProxyProvider` that watches
/// the `AuthenticationProvider`.
class GroupChatListProvider with ChangeNotifier {
  // --- UseCases ---
  final GetGroupChatsStreamUseCase _getGroupChatsStreamUseCase;
  final CreateGroupChatUseCase _createGroupChatUseCase;

  // --- State ---
  List<GroupChatEntity> _groupChats = [];
  bool _isLoading = false;
  String? _error;

  /// The provider's "memory" of the current user's ID.
  /// It's the single source of truth WITHIN this provider.
  String? _currentUserId;

  // --- Stream Subscriptions ---
  StreamSubscription<List<GroupChatEntity>>? _groupChatsSubscription;

  /// The constructor is simple and only requires its own UseCases.
  GroupChatListProvider({
    required GetGroupChatsStreamUseCase getGroupChatsStreamUseCase,
    required CreateGroupChatUseCase createGroupChatUseCase,
  })  : _getGroupChatsStreamUseCase = getGroupChatsStreamUseCase,
        _createGroupChatUseCase = createGroupChatUseCase {
    AppLogger.debug("GroupChatListProvider: Instance created.");
  }

  // --- Getters for the UI ---
  List<GroupChatEntity> get groupChats => _groupChats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Dependency Update Method ---

  /// The gateway for receiving updates from the `AuthenticationProvider`.
  /// This method is called by the `ChangeNotifierProxyProvider`.
  void updateDependencies(AuthenticationProvider authProvider) {
    final newUserId = authProvider.currentUserId;

    // 1. Compare the new user ID with the provider's internal "memory".
    if (newUserId != _currentUserId) {
      // 2. Update the internal memory.
      _currentUserId = newUserId;
      AppLogger.debug("GroupChatListProvider: Auth dependency updated. New User ID: $newUserId");

      // 3. React to the change based on the new internal state.
      if (_currentUserId != null) {
        _subscribeToGroupChats(_currentUserId!);
      } else {
        _resetState();
      }
    }
  }

  // --- Private Methods for State Management ---

  /// Subscribes to the group chats stream for the given user.
  void _subscribeToGroupChats(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _groupChatsSubscription?.cancel();
    _groupChatsSubscription = _getGroupChatsStreamUseCase(currentUserId: userId).listen(
          (groups) {
        _groupChats = groups;
        _isLoading = false;
        _error = null;
        AppLogger.info("GroupChatListProvider: Received ${groups.length} group chats.");
        notifyListeners();
      },
      onError: (e, stackTrace) {
        AppLogger.error("GroupChatListProvider: Error loading group chats stream", e, stackTrace);
        _groupChats = [];
        _isLoading = false;
        _error = "Error loading group chats.";
        notifyListeners();
      },
    );
  }

  /// Resets all data, for example on logout.
  void _resetState() {
    AppLogger.debug("GroupChatListProvider: User logged out, resetting state.");
    _groupChats = [];
    _isLoading = false;
    _error = null;
    _groupChatsSubscription?.cancel();
    notifyListeners();
  }

  // --- Public Methods for UI Interaction ---

  /// Explicitly triggers a reload of the group chats.
  void forceReloadGroupChats() {
    final userId = _currentUserId;
    if (userId != null) {
      AppLogger.info("GroupChatListProvider: Force reloading group chats.");
      _subscribeToGroupChats(userId);
    }
  }

  /// Creates a new group.
  /// Returns the group ID or null on failure.
  Future<String?> createNewGroup({
    required String name,
    required List<String> memberIds,
    required List<String> adminIds,
    String? imageUrl,
    String? initialTextMessage,
  }) async {
    // Correctly uses the internal _currentUserId field.
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      _error = "Not logged in, cannot create a group.";
      notifyListeners();
      return null;
    }

    // Ensure the creator is also a member and admin
    if (!memberIds.contains(userId)) memberIds.add(userId);
    if (!adminIds.contains(userId)) adminIds.add(userId);

    _error = null;

    MessageEntity? initialMessage;
    if (initialTextMessage != null && initialTextMessage.isNotEmpty) {
      initialMessage = MessageEntity(
        id: '', // Will be generated in the repo/data source
        fromId: userId,
        toId: '', // Will be the groupId in the repo/data source
        msg: initialTextMessage,
        type: 'text',
        createdAt: DateTime.now(),
      );
    }

    try {
      AppLogger.debug("GroupChatListProvider: Attempting to create new group: $name");
      final groupId = await _createGroupChatUseCase(
        name: name,
        memberIds: memberIds,
        adminIds: adminIds,
        currentUserId: userId,
        imageUrl: imageUrl,
        initialMessage: initialMessage,
      );

      if (groupId == null) {
        _error = "Could not create group.";
        AppLogger.warning("GroupChatListProvider: createNewGroup - groupId was null.");
      } else {
        AppLogger.info("GroupChatListProvider: Group $groupId created: $name.");
        _error = null; // Success
      }
      // The group list will be updated automatically by the stream.
      // We only notify to update the error state if necessary.
      if (_error != null) notifyListeners();
      return groupId;
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatListProvider: Error creating new group", e, stackTrace);
      _error = "An error occurred while creating the group.";
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    AppLogger.debug("GroupChatListProvider: Disposing...");
    _groupChatsSubscription?.cancel();
    super.dispose();
  }
}