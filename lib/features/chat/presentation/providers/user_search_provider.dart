import 'dart:async';
import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/find_chat_users_by_name_prefix_usecase.dart';
// Optional: import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart'; // Für "Meine Kontakte"

// Auth Provider (um den aktuellen User auszuschließen)
import '../../../auth/presentation/providers/auth_provider.dart';


// Core
import '../../../../core/utils/app_logger.dart';

class UserSearchProvider with ChangeNotifier {
  final FindChatUsersByNamePrefixUseCase _findUsersUseCase;
  // final GetChatUsersStreamByIdsUseCase _getContactsUseCase; // Für später
  final AuthenticationProvider _authProvider;

  UserSearchProvider({
    required FindChatUsersByNamePrefixUseCase findUsersUseCase,
    // required GetChatUsersStreamByIdsUseCase getContactsUseCase,
    required AuthenticationProvider authProvider,
  })  : _findUsersUseCase = findUsersUseCase,
  // _getContactsUseCase = getContactsUseCase,
        _authProvider = authProvider;

  List<ChatUserEntity> _searchResults = [];
  // List<ChatUserEntity> _myContacts = []; // Für später
  bool _isLoading = false;
  String? _error;
  String _currentQuery = "";

  Timer? _debounce; // Für verzögerte Sucheingabe

  // --- Getter ---
  List<ChatUserEntity> get searchResults => _searchResults;
  // List<ChatUserEntity> get myContacts => _myContacts; // Für später
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;

  // --- Methoden ---

  /// Sucht nach Benutzern basierend auf dem Query.
  /// Verwendet Debouncing, um nicht bei jeder Tasteneingabe eine Anfrage zu senden.
  void searchUsers(String query, {List<String> excludeIds = const []}) {
    _currentQuery = query.trim();
    _setError(null); // Fehler zurücksetzen bei neuer Suche

    if (_currentQuery.isEmpty) {
      _searchResults = [];
      _setLoading(false); // Nicht laden, wenn Query leer ist
      notifyListeners();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      AppLogger.debug("UserSearchProvider: Debounced search for '$_currentQuery'");
      _setLoading(true);
      notifyListeners(); // UI zeigen, dass geladen wird

      try {
        final results = await _findUsersUseCase(namePrefix: _currentQuery, excludeIds: excludeIds,);
        // Filtere den aktuellen Benutzer aus den Suchergebnissen
        final currentUserId = _authProvider.currentUserId;
        _searchResults = results.where((user) => user.id != currentUserId).toList();
        AppLogger.info("UserSearchProvider: Found ${_searchResults.length} users for query '$_currentQuery'.");
      } catch (e, stackTrace) {
        AppLogger.error("UserSearchProvider: Error searching users for '$_currentQuery'", e, stackTrace);
        _setError("Fehler bei der Benutzersuche.");
        _searchResults = [];
      } finally {
        _setLoading(false);
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _currentQuery = "";
    _searchResults = [];
    _isLoading = false;
    _error = null;
    _debounce?.cancel();
    notifyListeners();
  }

  // --- Private Hilfsmethoden ---
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    // notifyListeners(); // Wird oft von der aufrufenden Methode gemacht
  }

  void _setError(String? message) {
    _error = message;
    // notifyListeners();
  }


  @override
  void dispose() {
    AppLogger.debug("UserSearchProvider: Disposing...");
    _debounce?.cancel();
    super.dispose();
  }
}