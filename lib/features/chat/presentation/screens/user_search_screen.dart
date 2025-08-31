import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// Provider
import '../providers/user_search_provider.dart';

// Entities
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';

// Core
import '../../../../core/utils/app_logger.dart';

/// A screen that allows users to search for other users and select them.
///
/// This screen can be configured for single or multiple user selection.
/// It can also pre-load and display an initial set of selected users.
class UserSearchScreen extends StatefulWidget {
  /// Whether multiple users can be selected. Defaults to `false`.
  final bool multiSelectionEnabled;

  /// A list of user IDs that should be initially selected.
  final List<String> initialSelectedUserIds;

  /// The maximum number of users that can be selected.
  /// If `null`, there is no limit.
  final int? maxSelectionCount;

  /// A list of user IDs to exclude from the search results.
  final List<String> excludeUserIds;

  /// Creates a [UserSearchScreen].
  const UserSearchScreen({
    super.key,
    this.multiSelectionEnabled = false,
    this.initialSelectedUserIds = const [],
    this.maxSelectionCount,
    this.excludeUserIds = const [],
  });

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

/// The state for the [UserSearchScreen] widget.
class _UserSearchScreenState extends State<UserSearchScreen> {
  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();

  /// A set of user IDs that are currently selected in this session.
  late Set<String> _selectedUserIdsInSession;

  /// A map to store the details of the selected users.
  /// The key is the user ID and the value is the [ChatUserEntity].
  final Map<String, ChatUserEntity> _selectedUserDetailsMap = {};

  /// A flag to indicate if the details for the initial selection are being loaded.
  bool _isLoadingInitialDetails = false;

  @override
  void initState() {
    super.initState();
    _selectedUserIdsInSession = Set.from(widget.initialSelectedUserIds);
    if (widget.initialSelectedUserIds.isNotEmpty) {
      _loadDetailsForInitialSelection(widget.initialSelectedUserIds);
    }
    _searchController.addListener(() {
      context.read<UserSearchProvider>().searchUsers(
            _searchController.text,
            excludeIds: widget.excludeUserIds,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Displays a SnackBar with the given [message].
  ///
  /// The [isError] flag determines the background color of the SnackBar.
  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
    );
  }

  /// Loads the details for the initially selected users.
  ///
  /// The [userIds] parameter is a list of user IDs to load.
  Future<void> _loadDetailsForInitialSelection(List<String> userIds) async {
    if (!mounted) return;
    setState(() => _isLoadingInitialDetails = true);
    try {
      final useCase = context.read<GetChatUsersStreamByIdsUseCase>();
      // Attempt to get the first non-empty list of users, or an empty list if no users are found or userIds is empty.
      final initialUsers = await useCase(userIds: userIds).firstWhere((list) => list.isNotEmpty || userIds.isEmpty, orElse: () => []);
      if (!mounted) return;
      setState(() {
        for (var user in initialUsers) {
          _selectedUserDetailsMap[user.id] = user;
          _selectedUserIdsInSession.add(user.id);
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error("UserSearchScreen: Error loading initial user details", e, stackTrace);
      _showSnackbar("Error loading pre-selected users.", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitialDetails = false);
      }
    }
  }

  /// Toggles the selection state of the given [user].
  ///
  /// If multi-selection is enabled, this will add or remove the user from the
  /// selection set. If a maximum selection count is set and reached,
  /// a SnackBar message will be shown.
  void _toggleSelection(ChatUserEntity user) {
    setState(() {
      if (_selectedUserIdsInSession.contains(user.id)) {
        _selectedUserIdsInSession.remove(user.id);
        _selectedUserDetailsMap.remove(user.id);
      } else {
        if (widget.maxSelectionCount == null || _selectedUserIdsInSession.length < widget.maxSelectionCount!) {
          _selectedUserIdsInSession.add(user.id);
          _selectedUserDetailsMap[user.id] = user;
        } else {
          _showSnackbar("Maximum selection of ${widget.maxSelectionCount} reached.");
        }
      }
    });
  }

  /// Confirms the current selection and pops the screen, returning the selected users.
  void _confirmSelection() {
    final result = _selectedUserIdsInSession.map((id) => _selectedUserDetailsMap[id]).whereType<ChatUserEntity>().toList();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<UserSearchProvider>();
    final theme = Theme.of(context);
    final canConfirmSelection = widget.multiSelectionEnabled && _selectedUserIdsInSession.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search for users...",
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
          ),
        ),
        actions: [
          if (widget.multiSelectionEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: canConfirmSelection ? _confirmSelection : null,
                child: Text("Done (${_selectedUserIdsInSession.length})"),
              ),
            )
        ],
      ),
      body: _buildSearchResultsList(context, searchProvider),
    );
  }

  /// Builds the list of search results or appropriate placeholder widgets.
  ///
  /// Takes the current [context] and [provider] for user search.
  Widget _buildSearchResultsList(BuildContext context, UserSearchProvider provider) {
    final theme = Theme.of(context);

    if (_isLoadingInitialDetails) {
      return Center(child: Text("Loading pre-selection...", style: theme.textTheme.bodyLarge));
    }
    if (provider.isLoading && provider.currentQuery.isNotEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text("Error: ${provider.error}", style: TextStyle(color: theme.colorScheme.error)));
    }

    final displayedUsers = provider.searchResults;

    if (provider.currentQuery.isNotEmpty && displayedUsers.isEmpty && !provider.isLoading) {
      return Center(child: Text("No users found.", style: theme.textTheme.bodyLarge));
    }

    // If no search query and no initial details are loading, prompt user to search.
    // Also, if there are no displayed users yet (e.g. initial state before any search).
    if (displayedUsers.isEmpty && provider.currentQuery.isEmpty && !_isLoadingInitialDetails) {
      return Center(child: Text("Enter a name to search for users.", textAlign: TextAlign.center, style: theme.textTheme.bodyLarge));
    }

    List<ChatUserEntity> usersToDisplay = List.from(displayedUsers);
    // If the search query is empty but there are selected users, display them.
    // This handles the case where initial users were loaded and the search bar is cleared.
    if (provider.currentQuery.isEmpty && _selectedUserDetailsMap.isNotEmpty) {
      usersToDisplay = _selectedUserDetailsMap.values.where((user) => _selectedUserIdsInSession.contains(user.id)).toList();
      usersToDisplay.sort((a, b) => a.name.compareTo(b.name)); // Sort for consistent display
    }


    return ListView.builder(
      itemCount: usersToDisplay.length,
      itemBuilder: (context, index) {
        final user = usersToDisplay[index];
        final isSelected = _selectedUserIdsInSession.contains(user.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (user.imageUrl?.isNotEmpty ?? false) ? NetworkImage(user.imageUrl!) : null,
            child: (user.imageUrl?.isEmpty ?? true) ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : "?") : null,
          ),
          title: Text(user.name, style: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
          subtitle: user.isOnline == true
              ? Text("Online", style: TextStyle(color: theme.colorScheme.primary, fontSize: 12))
              : (user.lastActiveAt != null
                  ? Text("Last seen: ${DateFormat('dd.MM HH:mm').format(user.lastActiveAt!)}", style: TextStyle(fontSize: 12))
                  : Text("Offline", style: TextStyle(fontSize: 12))),
          trailing: widget.multiSelectionEnabled
              ? Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) => _toggleSelection(user),
                )
              : null,
          onTap: () {
            widget.multiSelectionEnabled ? _toggleSelection(user) : Navigator.of(context).pop(user);
          },
          selected: isSelected && widget.multiSelectionEnabled,
          selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
        );
      },
    );
  }
}
