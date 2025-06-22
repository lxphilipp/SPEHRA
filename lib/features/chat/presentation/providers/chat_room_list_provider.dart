import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Wichtig für Listen- und Map-Vergleiche

// Domain & Entities
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_chat_rooms_stream_usecase.dart';
import '../../domain/usecases/create_or_get_chat_room_usecase.dart';
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart'; // Wichtig für Partnerdetails

// Auth Feature
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class ChatRoomListProvider with ChangeNotifier {
  // --- UseCases ---
  final GetChatRoomsStreamUseCase _getChatRoomsStreamUseCase;
  final CreateOrGetChatRoomUseCase _createOrGetChatRoomUseCase;
  final GetChatUsersStreamByIdsUseCase _getChatUsersStreamByIdsUseCase;
  final AuthenticationProvider _authProvider;

  // --- Zustand (State) ---
  List<ChatRoomEntity> _chatRooms = [];
  Map<String, ChatUserEntity> _partnerDetailsMap = {};
  bool _isLoading = true;
  String? _error;

  // --- Stream Subscriptions ---
  StreamSubscription<List<ChatRoomEntity>>? _chatRoomsSubscription;
  StreamSubscription<List<ChatUserEntity>>? _partnerDetailsSubscription;
  StreamSubscription<UserEntity?>? _authSubscription;

  // --- Konstruktor ---
  ChatRoomListProvider({
    required GetChatRoomsStreamUseCase getChatRoomsStreamUseCase,
    required CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase,
    required GetChatUsersStreamByIdsUseCase getChatUsersStreamByIdsUseCase,
    required AuthenticationProvider authProvider,
  })  : _getChatRoomsStreamUseCase = getChatRoomsStreamUseCase,
        _createOrGetChatRoomUseCase = createOrGetChatRoomUseCase,
        _getChatUsersStreamByIdsUseCase = getChatUsersStreamByIdsUseCase,
        _authProvider = authProvider {
    AppLogger.debug("ChatRoomListProvider: Initializing...");

    _authSubscription = _authProvider.authStateChanges.listen(_onAuthStateChanged);
    _onAuthStateChanged(_authProvider.currentUser); // Initialen Zustand prüfen
  }

  // --- Getter für die UI ---
  List<ChatRoomEntity> get chatRooms => _chatRooms;
  Map<String, ChatUserEntity> get partnerDetailsMap => _partnerDetailsMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Private Methoden zur Zustandsverwaltung ---

  /// Reagiert auf Änderungen des Login-Status.
  void _onAuthStateChanged(UserEntity? user) {
    if (user != null && user.id.isNotEmpty) {
      _subscribeToChatRooms(user.id);
    } else {
      _clearAllDataAndNotify();
    }
  }

  /// Abonniert den Stream für die Chaträume des Benutzers.
  void _subscribeToChatRooms(String currentUserId) {
    AppLogger.info("ChatRoomListProvider: Subscribing to chat rooms for user $currentUserId.");
    _isLoading = true;
    notifyListeners();

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _getChatRoomsStreamUseCase(currentUserId: currentUserId).listen((rooms) {
      // ======================== HIER IST DER ENTSCHEIDENDE LOG ========================
        AppLogger.warning("--- STREAM-EVENT ERHALTEN ---");
        AppLogger.info("Anzahl der Räume vom Stream: ${rooms.length}");
        for (var room in rooms) {
          AppLogger.debug(
              "Raum-ID: ${room.id.substring(0, 10)}... | "
                  "hiddenFor: ${room.hiddenFor} | "
                  "Ist versteckt für '$currentUserId'? ${room.hiddenFor.contains(currentUserId)}"
          );
        }
        AppLogger.warning("--- ENDE STREAM-EVENT ---");
        // =================================================================================

        if (const ListEquality().equals(_chatRooms, rooms) && !_isLoading) {
          return;
        }
        _chatRooms = rooms;
        _isLoading = false;
        _error = null;

        // Nach dem Laden der Räume, lade die Details der Partner.
        _updatePartnerDetailsSubscription(currentUserId);

        notifyListeners();
      },
      onError: (e, stackTrace) {
        AppLogger.error("ChatRoomListProvider: Error in chat rooms stream", e, stackTrace);
        _setError("Could not load chats.");
      },
    );
  }

  /// Startet oder aktualisiert den Stream für die Profildetails der Chatpartner.
  void _updatePartnerDetailsSubscription(String currentUserId) {
    // 1. Sammle alle einzigartigen Partner-IDs aus den geladenen Chaträumen.
    final partnerIds = _chatRooms
        .map((room) => room.members.firstWhere((id) => id != currentUserId, orElse: () => ''))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (partnerIds.isEmpty) {
      _partnerDetailsSubscription?.cancel();
      _partnerDetailsMap = {};
      return;
    }

    AppLogger.debug("ChatRoomListProvider: Subscribing to details for partners: $partnerIds");

    // 2. Abonniere den Stream für genau diese Partner-IDs.
    _partnerDetailsSubscription?.cancel();
    _partnerDetailsSubscription = _getChatUsersStreamByIdsUseCase(userIds: partnerIds).listen(
            (partners) {
          final newMap = {for (var partner in partners) partner.id: partner};

          // Verhindere unnötige UI-Updates, wenn sich die Partner-Daten nicht geändert haben.
          if (const MapEquality().equals(_partnerDetailsMap, newMap)) return;

          _partnerDetailsMap = newMap;
          AppLogger.debug("ChatRoomListProvider: Received details for ${_partnerDetailsMap.length} partners.");
          notifyListeners();
        },
        onError: (e, s) {
          AppLogger.error("Error in partner details stream", e, s);
          // Hier könnte man einen nicht-blockierenden Fehler setzen.
        }
    );
  }

  /// Setzt alle Daten zurück, z.B. bei einem Logout.
  void _clearAllDataAndNotify() {
    AppLogger.debug("ChatRoomListProvider: Clearing all data.");
    _chatRoomsSubscription?.cancel();
    _partnerDetailsSubscription?.cancel();
    _chatRoomsSubscription = null;
    _partnerDetailsSubscription = null;
    _chatRooms = [];
    _partnerDetailsMap = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Interne Methode zum Setzen von Fehlern.
  void _setError(String message) {
    if (_error != message) {
      _error = message;
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Public Methoden für die UI ---

  /// Startet einen neuen Chat oder ruft einen existierenden ab.
  Future<String?> startNewChat(String partnerUserId, {String? initialTextMessage}) async {
    final currentUserId = _authProvider.currentUserId;
    if (currentUserId == null) {
      _setError("Not logged in.");
      return null;
    }
    if (currentUserId == partnerUserId) {
      _setError("You cannot start a chat with yourself.");
      return null;
    }

    try {
      final roomId = await _createOrGetChatRoomUseCase(
        currentUserId: currentUserId,
        partnerUserId: partnerUserId,
        initialMessage: initialTextMessage != null ? MessageEntity(id: '', fromId: currentUserId, toId: partnerUserId, msg: initialTextMessage, type: 'text') : null,
      );
      return roomId;
    } catch (e, stackTrace) {
      AppLogger.error("ChatRoomListProvider: Error starting new chat", e, stackTrace);
      _setError("Failed to start new chat.");
      return null;
    }
  }

  /// Löst explizit ein Neuladen der Chaträume aus.
  void forceReloadChatRooms() {
    final currentUserId = _authProvider.currentUserId;
    if (currentUserId != null) {
      AppLogger.info("ChatRoomListProvider: Force reloading chat rooms.");
      _subscribeToChatRooms(currentUserId);
    }
  }

  void testRemoveFirstChat() {
    if (_chatRooms.isNotEmpty) {
      AppLogger.warning("TEST: Removing first chat from the list manually.");
      _chatRooms.removeAt(0); // Entferne den ersten Chat aus der Liste
      notifyListeners();      // Benachrichtige die UI
    } else {
      AppLogger.warning("TEST: No chats to remove.");
    }
  }

  @override
  void dispose() {
    AppLogger.debug("ChatRoomListProvider: Disposing...");
    _chatRoomsSubscription?.cancel();
    _partnerDetailsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}