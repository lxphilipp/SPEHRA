import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart'; // Für Datumsformatierung

// Provider
import '../providers/user_search_provider.dart';

// Entities
import '../../domain/entities/chat_user_entity.dart';

// UseCases (wird für das Laden initialer Details benötigt)
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class UserSearchScreen extends StatefulWidget {
  final bool multiSelectionEnabled;
  final List<String> initialSelectedUserIds; // IDs der bereits ausgewählten User
  final int? maxSelectionCount;
  final List<String> excludeUserIds;

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

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Set<String> _selectedUserIdsInSession;
  Map<String, ChatUserEntity> _selectedUserDetailsMap = {};
  bool _isLoadingInitialDetails = false; // Ladezustand für initiale User-Details

  @override
  void initState() {
    super.initState();
    AppLogger.debug("UserSearchScreen: initState. MultiSelection: ${widget.multiSelectionEnabled}, Initial IDs: ${widget.initialSelectedUserIds}");
    _selectedUserIdsInSession = Set.from(widget.initialSelectedUserIds);

    if (widget.initialSelectedUserIds.isNotEmpty) {
      _loadDetailsForInitialSelection(widget.initialSelectedUserIds);
    }

    _searchController.addListener(() {
      // Debouncing ist im UserSearchProvider
      Provider.of<UserSearchProvider>(context, listen: false)
          .searchUsers(_searchController.text, excludeIds: widget.excludeUserIds,);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    AppLogger.debug("UserSearchScreen: dispose");
    super.dispose();
  }

  Future<void> _loadDetailsForInitialSelection(List<String> userIds) async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitialDetails = true;
    });
    AppLogger.debug("UserSearchScreen: Loading details for initial selection: $userIds");

    try {
      // Hole den UseCase über context.read, da dies in initState/einer Methode passiert
      final getChatUsersStreamByIdsUseCase = context.read<GetChatUsersStreamByIdsUseCase>();
      // Wir nehmen den ersten Wert des Streams, der nicht leer ist, oder eine leere Liste als Fallback.
      final initialUsers = await getChatUsersStreamByIdsUseCase(userIds: userIds).firstWhere(
            (list) => list.isNotEmpty || userIds.isEmpty, // Stoppe, wenn Liste gefüllt oder userIds leer war
        orElse: () => [], // Fallback, wenn Stream endet, bevor Bedingung erfüllt
      );

      if (!mounted) return;

      for (var user in initialUsers) {
        _selectedUserDetailsMap[user.id] = user;
        // Stelle sicher, dass die ID auch im Set ist, falls sie durch einen Fehler fehlte
        // (sollte durch die Initialisierung von _selectedUserIdsInSession schon abgedeckt sein)
        if (!_selectedUserIdsInSession.contains(user.id)) {
          _selectedUserIdsInSession.add(user.id);
        }
      }
      AppLogger.debug("UserSearchScreen: Loaded initial details. Map size: ${_selectedUserDetailsMap.length}. Selected IDs: $_selectedUserIdsInSession");
    } catch (e, stackTrace) {
      AppLogger.error("UserSearchScreen: Error loading initial user details", e, stackTrace);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fehler beim Laden der vorausgewählten Nutzer."), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialDetails = false;
        });
      }
    }
  }


  void _toggleSelection(ChatUserEntity user) {
    setState(() {
      if (_selectedUserIdsInSession.contains(user.id)) {
        _selectedUserIdsInSession.remove(user.id);
        _selectedUserDetailsMap.remove(user.id); // Entferne auch die Details
        AppLogger.debug("UserSearchScreen: User ${user.name} deselected. Current selection count: ${_selectedUserIdsInSession.length}");
      } else {
        if (widget.maxSelectionCount == null || _selectedUserIdsInSession.length < widget.maxSelectionCount!) {
          _selectedUserIdsInSession.add(user.id);
          _selectedUserDetailsMap[user.id] = user; // Füge die Details hinzu
          AppLogger.debug("UserSearchScreen: User ${user.name} selected. Current selection count: ${_selectedUserIdsInSession.length}");
        } else {
          AppLogger.info("UserSearchScreen: Max selection count (${widget.maxSelectionCount}) reached.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Maximale Auswahl von ${widget.maxSelectionCount} erreicht.")),
          );
        }
      }
    });
  }

  void _confirmSelection() {
    // Erstelle eine Liste der ausgewählten ChatUserEntity Objekte, basierend auf den IDs im Set
    // und den Details in der Map.
    final List<ChatUserEntity> result = _selectedUserIdsInSession
        .map((id) => _selectedUserDetailsMap[id])
        .where((user) => user != null) // Filtere null-Werte heraus (sollte nicht passieren, wenn Logik korrekt)
        .cast<ChatUserEntity>()
        .toList();

    AppLogger.info("UserSearchScreen: Confirming selection with ${result.length} users. Popping with result.");
    Navigator.of(context).pop(result); // Gibt die Liste der ausgewählten User zurück
  }

  @override
  Widget build(BuildContext context) {
    // context.watch hier, um bei Änderungen im UserSearchProvider neu zu bauen
    final searchProvider = context.watch<UserSearchProvider>();
    final theme = Theme.of(context);
    final bool canConfirmSelection = widget.multiSelectionEnabled && _selectedUserIdsInSession.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a0930), // Etwas anderer Ton für die Such-AppBar
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Nach Benutzern suchen...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Iconsax.close_circle, color: Colors.white70),
              onPressed: () {
                _searchController.clear(); // Triggert den Listener, der searchProvider.searchUsers('') aufruft
                // searchProvider.clearSearch(); // Wird durch leere Query im Listener erledigt
              },
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
                child: Text(
                  "Fertig (${_selectedUserIdsInSession.length})",
                  style: TextStyle(
                    color: canConfirmSelection ? theme.colorScheme.primary : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
        ],
      ),
      body: _buildSearchResultsList(context, searchProvider),
    );
  }

  Widget _buildSearchResultsList(BuildContext context, UserSearchProvider provider) {
    if (_isLoadingInitialDetails) {
      return const Center(child: Text("Lade Voreinstellungen...", style: TextStyle(color: Colors.white70)));
    }

    if (provider.isLoading && provider.currentQuery.isNotEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text("Fehler: ${provider.error}", style: const TextStyle(color: Colors.redAccent)));
    }

    // Kombiniere Suchergebnisse mit bereits ausgewählten Usern, die nicht in den Suchergebnissen sind,
    // damit der User seine gesamte Auswahl sieht und verwalten kann.
    // Dies ist eine komplexere Anforderung für die UI.
    // Einfacher Ansatz: Zeige nur Suchergebnisse und markiere die ausgewählten.
    final displayedUsers = provider.searchResults;

    if (provider.currentQuery.isNotEmpty && displayedUsers.isEmpty && !provider.isLoading) {
      return const Center(child: Text("Keine Benutzer für deine Suche gefunden.", style: TextStyle(color: Colors.white70)));
    }

    if (displayedUsers.isEmpty && provider.currentQuery.isEmpty && !_isLoadingInitialDetails) {
      // Wenn die Query leer ist und keine initialen Details geladen werden,
      // könnte man hier "Meine Kontakte" oder eine Aufforderung anzeigen.
      // Oder, wenn initialSelectedUserIds da waren, aber keine Details geladen werden konnten:
      if (widget.initialSelectedUserIds.isNotEmpty && _selectedUserDetailsMap.isEmpty) {
        return const Center(child: Text("Vorausgewählte Nutzer konnten nicht geladen werden.", style: TextStyle(color: Colors.orangeAccent)));
      }
      return const Center(child: Text("Gib einen Namen ein, um nach Benutzern zu suchen.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)));
    }

    // Wenn initial User ausgewählt wurden, aber die Suche leer ist, zeige trotzdem die initial ausgewählten
    // Dies ist eine Möglichkeit, die Auswahl sichtbar zu halten.
    List<ChatUserEntity> usersToDisplay = List.from(displayedUsers);
    if (provider.currentQuery.isEmpty && _selectedUserDetailsMap.isNotEmpty) {
      usersToDisplay = _selectedUserDetailsMap.values.where((user) => _selectedUserIdsInSession.contains(user.id)).toList();
      // Optional: Sortiere diese Liste
      usersToDisplay.sort((a,b) => a.name.compareTo(b.name));
    }


    return ListView.builder(
      itemCount: usersToDisplay.length,
      itemBuilder: (context, index) {
        final user = usersToDisplay[index];
        final bool isSelected = _selectedUserIdsInSession.contains(user.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                ? NetworkImage(user.imageUrl!)
                : null,
            child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white))
                : null,
            backgroundColor: Colors.grey[700],
          ),
          title: Text(user.name, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white)),
          subtitle: user.isOnline == true
              ? const Text("Online", style: TextStyle(color: Colors.greenAccent, fontSize: 12))
              : (user.lastActiveAt != null
              ? Text("Zuletzt: ${DateFormat('dd.MM HH:mm').format(user.lastActiveAt!)}", style: TextStyle(color: Colors.grey[500], fontSize: 12))
              : const Text("Offline", style: TextStyle(color: Colors.grey, fontSize: 12))),
          trailing: widget.multiSelectionEnabled
              ? Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              _toggleSelection(user);
            },
            activeColor: Theme.of(context).colorScheme.primary,
            checkColor: Colors.white,
            side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600]!),
          )
              : null,
          onTap: () {
            if (widget.multiSelectionEnabled) {
              _toggleSelection(user);
            } else {
              AppLogger.info("UserSearchScreen: Single user selected: ${user.name}. Popping with user.");
              Navigator.of(context).pop(user);
            }
          },
          selected: isSelected && widget.multiSelectionEnabled,
          selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Leichtere Hervorhebung
        );
      },
    );
  }
}