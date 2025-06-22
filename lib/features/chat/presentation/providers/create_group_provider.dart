import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/chat_user_entity.dart';

// Provider
import 'group_chat_list_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // Liefert UserEntity (id, name, email)

// Core
import '../../../../core/utils/app_logger.dart';

class CreateGroupProvider with ChangeNotifier {
  final GroupChatListProvider _groupChatListProvider;
  final AuthenticationProvider _authProvider;

  CreateGroupProvider({
    required GroupChatListProvider groupChatListProvider,
    required AuthenticationProvider authProvider,
  })  : _groupChatListProvider = groupChatListProvider,
        _authProvider = authProvider {
    AppLogger.debug("CreateGroupProvider: Initializing...");
    _initializeCreatorAsMember();
  }

  String _groupName = '';
  List<ChatUserEntity> _selectedMembers = [];
  bool _isCreatingGroup = false;
  String? _error;

  // --- Getter ---
  String get groupName => _groupName;
  List<ChatUserEntity> get selectedMembers => List.unmodifiable(_selectedMembers);
  bool get isCreatingGroup => _isCreatingGroup;
  String? get error => _error;

  // --- Private Initialisierung ---
  void _initializeCreatorAsMember() {
    final authUser = _authProvider.currentUser; // Dies ist UserEntity (id, name, email)

    if (authUser != null) {
      final creatorAsChatUser = ChatUserEntity(
        id: authUser.id,
        name: authUser.name ?? "You", // Fallback
        imageUrl: null, // UserEntity hat kein imageUrl, also explizit null
      );
      if (!_selectedMembers.any((m) => m.id == creatorAsChatUser.id)) {
        _selectedMembers = [creatorAsChatUser];
        AppLogger.debug("CreateGroupProvider: Initialized with creator: ${creatorAsChatUser.name}");
      }
    } else {
      AppLogger.warning("CreateGroupProvider: Cannot initialize creator as member, currentUserEntity is null.");
    }
  }

  // --- Methoden zur Zustandsänderung ---
  void setGroupName(String name) {
    final trimmedName = name.trim();
    if (_groupName == trimmedName) return;
    _groupName = trimmedName;
  }

  void setSelectedMembers(List<ChatUserEntity> membersFromSearch) {
    final currentAuthUser = _authProvider.currentUser;
    Set<ChatUserEntity> newSelectionSet = Set.from(membersFromSearch);

    if (currentAuthUser != null) {
      bool creatorInNewSelection = newSelectionSet.any((m) => m.id == currentAuthUser.id);

      if (!creatorInNewSelection) {

        newSelectionSet.add(ChatUserEntity(
          id: currentAuthUser.id,
          name: currentAuthUser.name ?? "You",
          imageUrl: null, // Explizit null
        ));
        AppLogger.debug("CreateGroupProvider: Creator (re-)added to selection based on AuthProvider info.");
      }
      // Wenn der Ersteller in `membersFromSearch` war, werden seine Details (potenziell mit Bild)
      // vom UserSearchScreen übernommen.
    }
    _selectedMembers = newSelectionSet.toList();
    _selectedMembers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    AppLogger.debug("CreateGroupProvider: Selected members updated. Count: ${_selectedMembers.length}");
    notifyListeners();
  }

  void removeMember(ChatUserEntity member) {
    final currentUserId = _authProvider.currentUserId;
    if (member.id == currentUserId && _selectedMembers.length == 1 && _selectedMembers.any((m)=> m.id == currentUserId)) {
      _error = "The group creator cannot be removed if they are the only member.";
      AppLogger.info("CreateGroupProvider: Attempted to remove the only member (creator).");
      notifyListeners();
      return;
    }
    _selectedMembers.removeWhere((m) => m.id == member.id);
    notifyListeners();
  }

  Future<String?> submitCreateGroup() async {
    if (_groupName.trim().isEmpty) { _error = "Please enter a group name."; notifyListeners(); return null; }
    final currentUserId = _authProvider.currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) { _error = "Error: Not logged in."; notifyListeners(); return null; }
    if (_selectedMembers.isEmpty || !_selectedMembers.any((m) => m.id == currentUserId)) {
      _error = "The creator must be a member of the group."; notifyListeners(); return null;
    }

    _isCreatingGroup = true; _error = null; notifyListeners();
    List<String> memberIds = _selectedMembers.map((m) => m.id).toList();
    List<String> adminIds = [currentUserId];

    try {
      final groupId = await _groupChatListProvider.createNewGroup(
        name: _groupName.trim(),
        memberIds: memberIds,
        adminIds: adminIds,
        imageUrl: null, // Kein Gruppenbild in dieser Version
        initialTextMessage: "Welcome to the group '$_groupName'!",
      );

      if (groupId != null) { _resetStateAfterSuccess(); return groupId; }
      else { _error = _groupChatListProvider.error ?? "Could not create group."; }
    } catch (e) { _error = "An error occurred."; AppLogger.error("CreateGroup Error", e); }
    finally { _isCreatingGroup = false; notifyListeners(); }
    return null;
  }

  void _resetStateAfterSuccess() {
    _groupName = '';
    _selectedMembers = [];
    _initializeCreatorAsMember();
  }

  @override
  void dispose() { AppLogger.debug("CreateGroupProvider: Disposing."); super.dispose(); }
}