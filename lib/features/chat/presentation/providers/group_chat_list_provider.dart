import 'dart:async';
import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/group_chat_entity.dart';
import '../../domain/entities/message_entity.dart'; // Für die initialMessage beim Erstellen
import '../../../auth/domain/entities/user_entity.dart'; // Für den Auth-Status

// UseCases
import '../../domain/usecases/get_group_chats_stream_usecase.dart';
import '../../domain/usecases/create_group_chat_usecase.dart';

// Auth Provider
import '../../../auth/presentation/providers/auth_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class GroupChatListProvider with ChangeNotifier {
  final GetGroupChatsStreamUseCase _getGroupChatsStreamUseCase;
  final CreateGroupChatUseCase _createGroupChatUseCase;
  final AuthenticationProvider _authProvider;

  List<GroupChatEntity> _groupChats = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<List<GroupChatEntity>>? _groupChatsSubscription;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  GroupChatListProvider({
    required GetGroupChatsStreamUseCase getGroupChatsStreamUseCase,
    required CreateGroupChatUseCase createGroupChatUseCase,
    required AuthenticationProvider authProvider,
  })  : _getGroupChatsStreamUseCase = getGroupChatsStreamUseCase,
        _createGroupChatUseCase = createGroupChatUseCase,
        _authProvider = authProvider {
    AppLogger.debug("GroupChatListProvider: Initializing...");
    _authStateSubscription = _authProvider.authStateChanges.listen(_onAuthStateChanged);
    _loadGroupChatsIfNeeded(isInitialCall: true);
  }

  // --- Getter ---
  List<GroupChatEntity> get groupChats => _groupChats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentUserId => _authProvider.currentUserId ?? '';


  // --- Private Methoden ---
  void _onAuthStateChanged(UserEntity? user) {
    AppLogger.debug("GroupChatListProvider: Auth state changed. User: ${user?.id}");
    _loadGroupChatsIfNeeded();
  }

  void _loadGroupChatsIfNeeded({bool isInitialCall = false}) {
    final userId = currentUserId; // currentUserId vom Getter verwenden
    AppLogger.debug("GroupChatListProvider: _loadGroupChatsIfNeeded called. CurrentUserId: $userId, IsLoggedIn: ${_authProvider.isLoggedIn}, IsInitialCall: $isInitialCall");

    if (userId.isNotEmpty && _authProvider.isLoggedIn) {
      if (_isLoading && !isInitialCall) {
        AppLogger.debug("GroupChatListProvider: Already loading, skipping reload.");
        return;
      }

      _isLoading = true;
      _error = null;
      if (!isInitialCall || _groupChats.isNotEmpty || _error != null) {
        notifyListeners();
      }

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
          _error = "Fehler beim Laden der Gruppenchats.";
          notifyListeners();
        },
      );
    } else {
      AppLogger.debug("GroupChatListProvider: User not logged in or no UserId, resetting state.");
      if (_groupChats.isNotEmpty || _isLoading || _error != null) {
        _groupChats = [];
        _isLoading = false;
        _error = null;
        _groupChatsSubscription?.cancel();
        _groupChatsSubscription = null;
        notifyListeners();
      } else {
        _groupChatsSubscription?.cancel();
        _groupChatsSubscription = null;
      }
    }
  }

  // --- Public Methoden ---
  void forceReloadGroupChats() {
    AppLogger.info("GroupChatListProvider: forceReloadGroupChats called.");
    _isLoading = true;
    _error = null;
    notifyListeners(); // UI zeigen, dass wir neu laden
    _loadGroupChatsIfNeeded();
  }

  /// Erstellt eine neue Gruppe.
  /// Gibt die Gruppen-ID zurück oder null bei Fehler.
  Future<String?> createNewGroup({
    required String name,
    required List<String> memberIds, // Muss den currentUserId bereits enthalten
    required List<String> adminIds,  // Muss den currentUserId bereits enthalten
    String? imageUrl,
    String? initialTextMessage,
  }) async {
    final userId = currentUserId;
    if (userId.isEmpty) {
      _error = "Nicht eingeloggt, um eine Gruppe zu erstellen.";
      notifyListeners();
      return null;
    }

    // Sicherstellen, dass der Ersteller auch Mitglied und Admin ist
    if (!memberIds.contains(userId)) memberIds.add(userId);
    if (!adminIds.contains(userId)) adminIds.add(userId);


    _error = null; // Fehler vor dem Versuch zurücksetzen
    // Ein spezifischer Ladezustand für diese Aktion könnte hier nützlich sein,
    // z.B. _isCreatingGroup, um einen Button im UI zu deaktivieren.

    MessageEntity? initialMessage;
    if (initialTextMessage != null && initialTextMessage.isNotEmpty) {
      initialMessage = MessageEntity(
        id: '', // Wird im Repo/DS generiert
        fromId: userId,
        toId: '', // Wird im Repo/DS die groupId sein
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
        currentUserId: userId, // Wird für die initialMessage benötigt
        imageUrl: imageUrl,
        initialMessage: initialMessage,
      );

      if (groupId == null) {
        _error = "Gruppe konnte nicht erstellt werden.";
        AppLogger.warning("GroupChatListProvider: createNewGroup - groupId was null.");
      } else {
        AppLogger.info("GroupChatListProvider: Group $groupId created: $name.");
        _error = null; // Erfolgreich
      }
      // Die Gruppenliste wird automatisch durch den Stream aktualisiert.
      notifyListeners(); // Um ggf. _error zu aktualisieren
      return groupId;
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatListProvider: Error creating new group", e, stackTrace);
      _error = "Fehler beim Erstellen der Gruppe.";
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    AppLogger.debug("GroupChatListProvider: Disposing...");
    _groupChatsSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
    AppLogger.debug("GroupChatListProvider: Disposed.");
  }
}