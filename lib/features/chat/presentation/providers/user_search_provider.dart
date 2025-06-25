// lib/features/chat/presentation/providers/user_search_provider.dart

import 'dart:async';

import 'package:flutter/cupertino.dart';


// Core
import '../../../../core/utils/app_logger.dart';

// Dependencies: Providers and Entities
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/usecases/find_chat_users_by_name_prefix_usecase.dart';


/// Manages the state for searching chat users.
///
/// This provider handles:
/// - Debouncing user input to prevent excessive backend queries.
/// - Calling the use case to find users by a name prefix.
/// - Excluding the current user from the search results.
/// It is designed to be updated by a `ChangeNotifierProxyProvider`.
class UserSearchProvider with ChangeNotifier {
  // --- UseCases ---
  final FindChatUsersByNamePrefixUseCase _findUsersUseCase;

  // --- Internal Provider References ---
  // This will be kept up-to-date by the `updateDependencies` method.
  late AuthenticationProvider _authProvider;

  // --- State ---
  List<ChatUserEntity> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = "";

  Timer? _debounce; // For debouncing search input

  /// The constructor is now simple and only requires its own UseCase.
  UserSearchProvider({
    required FindChatUsersByNamePrefixUseCase findUsersUseCase,
  }) : _findUsersUseCase = findUsersUseCase;


  // --- Getters for the UI ---
  List<ChatUserEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;

  // --- Dependency Update Method ---

  /// The gateway for receiving updates from the `AuthenticationProvider`.
  void updateDependencies(AuthenticationProvider auth) {
    _authProvider = auth;
    // In this provider, we don't need to trigger an action immediately
    // when the auth state changes, because a search is only initiated
    // by user input. This method's job is just to ensure our internal
    // `_authProvider` reference is always up-to-date for the next search.
  }

  // --- Public Methods ---

  /// Searches for users based on a query.
  /// Uses debouncing to avoid sending a request on every keystroke.
  void searchUsers(String query, {List<String> excludeIds = const []}) {
    _currentQuery = query.trim();
    _setError(null); // Reset error on new search

    if (_currentQuery.isEmpty) {
      _searchResults = [];
      _setLoading(false);
      notifyListeners();
      return;
    }

    // If a timer is already active, cancel it.
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer. The search will only run after 500ms of no new input.
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      AppLogger.debug("UserSearchProvider: Debounced search for '$_currentQuery'");
      _setLoading(true);
      notifyListeners(); // Show loading indicator in the UI

      final currentUserId = _authProvider.currentUserId;
      var allExcludedIds = {...excludeIds, if (currentUserId != null) currentUserId}.toList();

      try {
        final results = await _findUsersUseCase(
          namePrefix: _currentQuery,
          excludeIds: allExcludedIds,
        );
        _searchResults = results;
        AppLogger.info("UserSearchProvider: Found ${_searchResults.length} users for query '$_currentQuery'.");
      } catch (e, stackTrace) {
        AppLogger.error("UserSearchProvider: Error searching users for '$_currentQuery'", e, stackTrace);
        _setError("Error while searching for users.");
        _searchResults = [];
      } finally {
        _setLoading(false);
        notifyListeners();
      }
    });
  }

  /// Clears the current search query and results.
  void clearSearch() {
    _currentQuery = "";
    _searchResults = [];
    _isLoading = false;
    _error = null;
    _debounce?.cancel();
    notifyListeners();
  }

  // --- Private Helper Methods ---
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
  }

  void _setError(String? message) {
    if (_error == message) return;
    _error = message;
  }

  @override
  void dispose() {
    AppLogger.debug("UserSearchProvider: Disposing...");
    _debounce?.cancel(); // Important: cancel the timer to prevent memory leaks.
    super.dispose();
  }
}