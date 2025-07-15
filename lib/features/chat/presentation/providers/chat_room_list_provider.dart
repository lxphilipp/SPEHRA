// lib/features/chat/presentation/providers/chat_room_list_provider.dart

import 'dart:async';

import 'package:collection/collection.dart'; // For deep list/map equality checks
import 'package:flutter/cupertino.dart';

// Domain & Entities
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_chat_rooms_stream_usecase.dart';
import '../../domain/usecases/create_or_get_chat_room_usecase.dart';
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';

// Auth Feature
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

/// Manages the state for the list of 1-on-1 chat rooms.
///
/// This provider is responsible for:
/// - Subscribing to the user's chat rooms based on their auth state.
/// - Fetching the profile details of the chat partners.
/// - Providing methods to create new chats.
/// It is designed to be updated by a `ChangeNotifierProxyProvider` that watches
/// the `AuthenticationProvider`.
class ChatRoomListProvider with ChangeNotifier {
  // --- UseCases ---
  final GetChatRoomsStreamUseCase _getChatRoomsStreamUseCase;
  final CreateOrGetChatRoomUseCase _createOrGetChatRoomUseCase;
  final GetChatUsersStreamByIdsUseCase _getChatUsersStreamByIdsUseCase;

  // --- State ---
  List<ChatRoomEntity> _chatRooms = [];
  Map<String, ChatUserEntity> _partnerDetailsMap = {};
  bool _isLoading = false;
  String? _error;

  /// The provider's "memory" of the current user's ID.
  /// It's the single source of truth WITHIN this provider.
  String? _currentUserId;

  // --- NEU: Sortier-Zustand ---
  String _sortCriteria = 'lastMessageTime';
  bool _isSortAscending = false; // false = descending (neueste zuerst)

  // --- Stream Subscriptions ---
  StreamSubscription<List<ChatRoomEntity>>? _chatRoomsSubscription;
  StreamSubscription<List<ChatUserEntity>>? _partnerDetailsSubscription;

  /// The constructor is simple and only requires its own UseCases.
  ChatRoomListProvider({
    required GetChatRoomsStreamUseCase getChatRoomsStreamUseCase,
    required CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase,
    required GetChatUsersStreamByIdsUseCase getChatUsersStreamByIdsUseCase,
  })  : _getChatRoomsStreamUseCase = getChatRoomsStreamUseCase,
        _createOrGetChatRoomUseCase = createOrGetChatRoomUseCase,
        _getChatUsersStreamByIdsUseCase = getChatUsersStreamByIdsUseCase {
    AppLogger.debug("ChatRoomListProvider: Instance created.");
  }

  // --- Getters for the UI ---
  Map<String, ChatUserEntity> get partnerDetailsMap => _partnerDetailsMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ChatRoomEntity> get sortedChatRooms {
    List<ChatRoomEntity> sorted = List.from(_chatRooms);
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


  /// The gateway for receiving updates from the `AuthenticationProvider`.
  /// This method is called by the `ChangeNotifierProxyProvider`.
  void updateDependencies(AuthenticationProvider authProvider) {
    final newUserId = authProvider.currentUserId;

    // 1. Compare the new user ID with the provider's internal "memory".
    if (newUserId != _currentUserId) {
      // 2. Update the internal memory.
      _currentUserId = newUserId;
      AppLogger.debug(
          "ChatRoomListProvider: Auth dependency updated. New User ID: $newUserId");

      // 3. React to the change based on the new internal state.
      if (_currentUserId != null) {
        _subscribeToAllChatData(_currentUserId!);
      } else {
        _clearAllDataAndNotify();
      }
    }
  }

  // --- Private Methods for State Management ---

  /// Subscribes to the chat rooms stream for the given user.
  void _subscribeToAllChatData(String userId) {
    AppLogger.info(
        "ChatRoomListProvider: Subscribing to all chat data for user $userId.");
    _isLoading = true;
    _error = null;
    notifyListeners();

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription =
        _getChatRoomsStreamUseCase(currentUserId: userId).listen(
              (rooms) {
            // Prevent unnecessary updates if the list is identical.
            if (const ListEquality().equals(_chatRooms, rooms) && !_isLoading) {
              return;
            }
            _chatRooms = rooms;
            _isLoading = false;

            // After loading the rooms, fetch the details of the partners.
            _updatePartnerDetailsSubscription();

            notifyListeners();
          },
          onError: (e, stackTrace) {
            AppLogger.error(
                "ChatRoomListProvider: Error in chat rooms stream", e, stackTrace);
            _setError("Could not load chats.");
          },
        );
  }

  /// Starts or updates the stream for the profile details of chat partners.
  void _updatePartnerDetailsSubscription() {
    final userId = _currentUserId;
    if (userId == null) return;

    // 1. Collect all unique partner IDs from the loaded chat rooms.
    final partnerIds = _chatRooms
        .map((room) =>
        room.members.firstWhere((id) => id != userId, orElse: () => ''))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (partnerIds.isEmpty) {
      _partnerDetailsSubscription?.cancel();
      // Only update if the map is not already empty to prevent extra notifies.
      if (_partnerDetailsMap.isNotEmpty) {
        _partnerDetailsMap = {};
        notifyListeners();
      }
      return;
    }

    AppLogger.debug(
        "ChatRoomListProvider: Subscribing to details for partners: $partnerIds");

    // 2. Subscribe to the stream for exactly these partner IDs.
    _partnerDetailsSubscription?.cancel();
    _partnerDetailsSubscription =
        _getChatUsersStreamByIdsUseCase(userIds: partnerIds).listen(
              (partners) {
            final newMap = {for (var partner in partners) partner.id: partner};

            // Prevent unnecessary UI updates if the partner data hasn't changed.
            if (const MapEquality().equals(_partnerDetailsMap, newMap)) return;

            _partnerDetailsMap = newMap;
            AppLogger.debug(
                "ChatRoomListProvider: Received details for ${_partnerDetailsMap.length} partners.");
            notifyListeners();
          },
          onError: (e, s) {
            AppLogger.error("Error in partner details stream", e, s);
            // Optionally set a non-blocking error for partner details.
          },
        );
  }

  /// Resets all data, for example on logout.
  void _clearAllDataAndNotify() {
    AppLogger.debug("ChatRoomListProvider: Clearing all data.");
    _chatRoomsSubscription?.cancel();
    _partnerDetailsSubscription?.cancel();
    _chatRooms = [];
    _partnerDetailsMap = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Internal method for setting errors.
  void _setError(String message) {
    if (_error != message) {
      _error = message;
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Public Methods for UI Interaction ---

  /// Starts a new chat or retrieves an existing one.
  Future<String?> startNewChat(String partnerUserId,
      {String? initialTextMessage}) async {
    // Correctly uses the internal _currentUserId field.
    final userId = _currentUserId;

    if (userId == null) {
      _setError("Not logged in.");
      return null;
    }
    if (userId == partnerUserId) {
      _setError("You cannot start a chat with yourself.");
      return null;
    }

    try {
      final roomId = await _createOrGetChatRoomUseCase(
        currentUserId: userId,
        partnerUserId: partnerUserId,
        initialMessage: initialTextMessage != null
            ? MessageEntity(
          id: '', // Will be generated in the repo/data source
          fromId: userId,
          toId: partnerUserId,
          msg: initialTextMessage,
          type: 'text',
          createdAt: DateTime.now(),
        )
            : null,
      );
      return roomId;
    } catch (e, stackTrace) {
      AppLogger.error(
          "ChatRoomListProvider: Error starting new chat", e, stackTrace);
      _setError("Failed to start new chat.");
      return null;
    }
  }

  /// Explicitly triggers a reload of the chat rooms.
  void forceReloadChatRooms() {
    final userId = _currentUserId;
    if (userId != null) {
      AppLogger.info("ChatRoomListProvider: Force reloading chat rooms.");
      _subscribeToAllChatData(userId);
    }
  }

  @override
  void dispose() {
    AppLogger.debug("ChatRoomListProvider: Disposing...");
    _chatRoomsSubscription?.cancel();
    _partnerDetailsSubscription?.cancel();
    super.dispose();
  }
}