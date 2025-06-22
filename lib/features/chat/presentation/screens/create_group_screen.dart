import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart'; // For Icons

// Provider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/create_group_provider.dart';
// AuthenticationProvider is used indirectly via CreateGroupProvider

// Entities
import '../../domain/entities/chat_user_entity.dart';

// Screens
import 'user_search_screen.dart'; // For member selection
import 'group_chat_screen.dart'; // For navigation after success

// Core
import '../../../../core/utils/app_logger.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _openUserSearchForMembers(BuildContext context) async {
    final createGroupProvider = context.read<CreateGroupProvider>();
    AppLogger.debug("CreateGroupScreen: Opening user search. Initial selected IDs: ${createGroupProvider.selectedMembers.map((e) => e.id).toList()}");

    final List<ChatUserEntity>? resultFromSearch =
    await Navigator.of(context).push<List<ChatUserEntity>>(
      MaterialPageRoute(
        builder: (_) => UserSearchScreen(
          multiSelectionEnabled: true,
          initialSelectedUserIds: createGroupProvider.selectedMembers.map((m) => m.id).toList(),
        ),
      ),
    );

    if (resultFromSearch != null) {
      AppLogger.debug("CreateGroupScreen: Received ${resultFromSearch.length} members from search.");
      createGroupProvider.setSelectedMembers(resultFromSearch);
    } else {
      AppLogger.debug("CreateGroupScreen: User search for members was cancelled or returned null.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final createGroupProvider = context.watch<CreateGroupProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        title: const Text("Create New Group", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff040324),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: createGroupProvider.isCreatingGroup
                  ? null
                  : () async {
                createGroupProvider.setGroupName(_groupNameController.text);
                AppLogger.info("CreateGroupScreen: 'Create' button pressed.");
                final groupId = await createGroupProvider.submitCreateGroup();

                if (!context.mounted) return;

                if (groupId != null) {
                  AppLogger.info("CreateGroupScreen: Group created (ID: $groupId). Navigating.");
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => GroupChatScreen(
                        groupId: groupId,
                        initialGroupName: createGroupProvider.groupName,
                      ),
                    ),
                    ModalRoute.withName('/chat'), // Adjust to your main chat route
                  );
                } else if (createGroupProvider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(createGroupProvider.error!), backgroundColor: Colors.red),
                  );
                }
              },
              child: createGroupProvider.isCreatingGroup
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text(
                "Create",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder for group image selection
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              child: Icon(Iconsax.people, size: 50, color: Colors.grey[400]),
            ),
            const SizedBox(height: 30),

            // Group Name
            TextField(
              controller: _groupNameController,
              enabled: !createGroupProvider.isCreatingGroup,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: "Group Name",
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: "What's the name of your group?",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Iconsax.edit, color: Colors.grey[400]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                filled: true,
                fillColor: Colors.grey[850]?.withOpacity(0.5),
              ),
              onChanged: (name) => createGroupProvider.setGroupName(name),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 30),

            // Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Members (${createGroupProvider.selectedMembers.length})",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)
                ),
                IconButton(
                  icon: Icon(Iconsax.user_add, color: theme.colorScheme.primary, size: 28),
                  onPressed: createGroupProvider.isCreatingGroup ? null : () => _openUserSearchForMembers(context),
                  tooltip: "Add/Edit Members",
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (createGroupProvider.selectedMembers.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey[850]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: const Text(
                  "Add members to your group by tapping the icon above.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: createGroupProvider.selectedMembers.map((member) {
                      bool canDelete = !(member.id == context.read<AuthenticationProvider>().currentUserId &&
                          createGroupProvider.selectedMembers.length == 1);
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundImage: (member.imageUrl != null && member.imageUrl!.isNotEmpty)
                              ? NetworkImage(member.imageUrl!)
                              : null,
                          child: (member.imageUrl == null || member.imageUrl!.isEmpty)
                              ? Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : "?")
                              : null,
                        ),
                        label: Text(member.name),
                        backgroundColor: theme.chipTheme.backgroundColor?.withOpacity(0.5) ?? Colors.grey[700],
                        labelStyle: theme.chipTheme.labelStyle?.copyWith(color: Colors.white),
                        onDeleted: createGroupProvider.isCreatingGroup || !canDelete
                            ? null
                            : () => createGroupProvider.removeMember(member),
                        deleteIcon: const Icon(Iconsax.close_circle, size: 18),
                        deleteIconColor: canDelete ? Colors.redAccent.withOpacity(0.7) : Colors.grey.withOpacity(0.5),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Error Display
            if (createGroupProvider.error != null && !createGroupProvider.isCreatingGroup)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  createGroupProvider.error!,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}