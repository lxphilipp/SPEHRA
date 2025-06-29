import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/create_group_provider.dart';

// Entities
import '../../domain/entities/chat_user_entity.dart';

// Screens
import 'user_search_screen.dart';
import 'group_chat_screen.dart';

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
    // ... (logic remains the same)
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
      createGroupProvider.setSelectedMembers(resultFromSearch);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createGroupProvider = context.watch<CreateGroupProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      // OPTIMIERT: Farben und Stile werden jetzt vom globalen Theme gesteuert.
      appBar: AppBar(
        title: const Text("Create New Group"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: createGroupProvider.isCreatingGroup
                  ? null
                  : () async {
                createGroupProvider.setGroupName(_groupNameController.text);
                final groupId = await createGroupProvider.submitCreateGroup();

                if (!mounted) return;

                if (groupId != null) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => GroupChatScreen(
                        groupId: groupId,
                        initialGroupName: createGroupProvider.groupName,
                      ),
                    ),
                        (route) => route.isFirst,
                  );
                } else if (createGroupProvider.error != null) {
                  _showErrorSnackbar(createGroupProvider.error!);
                }
              },
              child: createGroupProvider.isCreatingGroup
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
              )
                  : const Text("Create"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // OPTIMIERT: Verwendet Farben aus dem ColorScheme
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.surfaceVariant,
              child: Icon(Iconsax.people, size: 50, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 30),

            // OPTIMIERT: Nutzt das globale InputDecorationTheme
            TextField(
              controller: _groupNameController,
              enabled: !createGroupProvider.isCreatingGroup,
              decoration: const InputDecoration(
                labelText: "Group Name",
                hintText: "What's the name of your group?",
                prefixIcon: Icon(Iconsax.edit),
              ),
              onChanged: (name) => createGroupProvider.setGroupName(name),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Members (${createGroupProvider.selectedMembers.length})",
                  style: theme.textTheme.titleLarge,
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
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "Add members to your group by tapping the icon above.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else
            // OPTIMIERT: Die Chips erben ihr Aussehen jetzt vom ChipTheme
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: createGroupProvider.selectedMembers.map((member) {
                    final bool isCreator = member.id == context.read<AuthenticationProvider>().currentUserId;
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundImage: (member.imageUrl?.isNotEmpty ?? false) ? NetworkImage(member.imageUrl!) : null,
                        child: (member.imageUrl?.isEmpty ?? true) ? Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : "?") : null,
                      ),
                      label: Text(member.name),
                      onDeleted: createGroupProvider.isCreatingGroup || isCreator
                          ? null
                          : () => createGroupProvider.removeMember(member),
                      deleteIconColor: theme.colorScheme.error,
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 30),

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