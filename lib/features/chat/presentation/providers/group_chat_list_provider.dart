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

class GroupChatListProvider with ChangeNotifier {
  // --- UseCases ---
  final GetGroupChatsStreamUseCase _getGroupChatsStreamUseCase;
  final CreateGroupChatUseCase _createGroupChatUseCase;

  // --- State ---
  List<GroupChatEntity> _groupChats = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  String _sortCriteria = 'lastMessageTime';
  bool _isSortAscending = false; // false = descending (neueste zuerst)

  // --- Stream Subscriptions ---
  StreamSubscription<List<GroupChatEntity>>? _groupChatsSubscription;



  GroupChatListProvider({
    required GetGroupChatsStreamUseCase getGroupChatsStreamUseCase,
    required CreateGroupChatUseCase createGroupChatUseCase,
  })  : _getGroupChatsStreamUseCase = getGroupChatsStreamUseCase,
        _createGroupChatUseCase = createGroupChatUseCase {
    AppLogger.debug("GroupChatListProvider: Instance created.");
  }

  // --- Getters for the UI ---
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<GroupChatEntity> get sortedGroupChats {
    List<GroupChatEntity> sorted = List.from(_groupChats);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortCriteria) {
        case 'lastMessageTime':
        default:
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          comparison = aTime.compareTo(bTime);
          break;
      }
      return _isSortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  List<GroupChatEntity> get groupChats => _groupChats;

  void setSortCriteria(String newSortValue) {
    final parts = newSortValue.split('_');
    final newCriteria = parts[0];
    final newDirectionIsAsc = (parts.length > 1 && parts[1] == 'asc');

    if (_sortCriteria != newCriteria || _isSortAscending != newDirectionIsAsc) {
      _sortCriteria = newCriteria;
      _isSortAscending = newDirectionIsAsc;
      notifyListeners();
    }
  }

  void updateDependencies(AuthenticationProvider authProvider) {
    final newUserId = authProvider.currentUserId;

    if (newUserId != _currentUserId) {
      _currentUserId = newUserId;
      AppLogger.debug("GroupChatListProvider: Auth dependency updated. New User ID: $newUserId");

      if (_currentUserId != null) {
        _subscribeToGroupChats(_currentUserId!);
      } else {
        _resetState();
      }
    }
  }

  void _subscribeToGroupChats(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _groupChatsSubscription?.cancel();
    _groupChatsSubscription = _getGroupChatsStreamUseCase(currentUserId: userId).listen(
          (groups) {
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
        _groupChats = [];
        _isLoading = false;
        _error = "Error loading group chats.";
        notifyListeners();
      },
    );
  }

  void _resetState() {
    AppLogger.debug("GroupChatListProvider: User logged out, resetting state.");
    _groupChats = [];
    _isLoading = false;
    _error = null;
    _groupChatsSubscription?.cancel();
    notifyListeners();
  }

  void forceReloadGroupChats() {
    final userId = _currentUserId;
    if (userId != null) {
      AppLogger.info("GroupChatListProvider: Force reloading group chats.");
      _subscribeToGroupChats(userId);
    }
  }

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
      notifyListeners();
      return null;
    }

    if (!memberIds.contains(userId)) memberIds.add(userId);
    if (!adminIds.contains(userId)) adminIds.add(userId);

    _error = null;

    MessageEntity? initialMessage;
    if (initialTextMessage != null && initialTextMessage.isNotEmpty) {
      initialMessage = MessageEntity(
        id: '',
        fromId: userId,
        toId: '',
        msg: initialTextMessage,
        type: MessageType.text,
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
        _error = null;
      }
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