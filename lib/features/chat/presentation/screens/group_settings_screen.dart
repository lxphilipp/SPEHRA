import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider & Entities
import '../providers/group_chat_provider.dart';
import '../../domain/entities/chat_user_entity.dart';
import 'user_search_screen.dart'; // Für die Mitgliedersuche

// Core
import '../../../../core/utils/app_logger.dart';

class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupChatProvider>();
    final theme = Theme.of(context);

    if (provider.groupDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Group Info")),
        body: const Center(child: Text("Group details not available.")),
      );
    }

    final group = provider.groupDetails!;
    final bool amIAdmin = provider.amIAdmin;

    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        title: const Text("Group Info", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff040324),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Gruppenkopf ---
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: group.imageUrl != null ? NetworkImage(group.imageUrl!) : null,
                      child: group.imageUrl == null
                          ? const Icon(Iconsax.people, size: 40, color: Colors.white70)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        if (amIAdmin)
                          IconButton(
                            icon: const Icon(Iconsax.edit, color: Colors.white70, size: 20),
                            onPressed: () => _showEditNameDialog(context, provider, group.name),
                          ),
                      ],
                    ),
                    Text(
                      "${group.memberIds.length} members",
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),

              // --- Mitgliederliste ---
              Text(
                "Members",
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              if(amIAdmin)
                ListTile(
                  leading: const Icon(Iconsax.user_add, color: Colors.green),
                  title: const Text("Add Members", style: TextStyle(color: Colors.green)),
                  onTap: () => _navigateAndAddMembers(context, provider),
                  contentPadding: EdgeInsets.zero,
                ),

              // Liste der Mitglieder rendern
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.memberIds.length,
                itemBuilder: (ctx, index) {
                  final memberId = group.memberIds[index];
                  final memberDetails = provider.getMemberDetail(memberId);
                  final bool isMemberAdmin = group.adminIds.contains(memberId);

                  return Card(
                    color: Colors.grey.shade900.withOpacity(0.5),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (memberDetails?.imageUrl != null)
                            ? NetworkImage(memberDetails!.imageUrl!)
                            : null,
                        child: (memberDetails?.imageUrl == null)
                            ? Text(memberDetails?.name.substring(0, 1).toUpperCase() ?? "?")
                            : null,
                      ),
                      title: Text(memberDetails?.name ?? "Loading...", style: const TextStyle(color: Colors.white)),
                      trailing: isMemberAdmin ? const Text("Admin", style: TextStyle(color: Colors.cyan, fontSize: 12)) : null,
                      onLongPress: (amIAdmin && memberId != provider.currentUserId)
                          ? () => _showRemoveMemberDialog(context, provider, memberDetails!)
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),

              // --- Aktionen ---
              ListTile(
                leading: const Icon(Iconsax.logout, color: Colors.redAccent),
                title: const Text("Leave Group", style: TextStyle(color: Colors.redAccent)),
                onTap: () => _showLeaveOrDeleteDialog(context, provider),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dialog-Hilfsmethoden ---

  void _showEditNameDialog(BuildContext context, GroupChatProvider provider, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Group Name"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              provider.updateGroupName(controller.text);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, GroupChatProvider provider, ChatUserEntity member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text("Are you sure you want to remove ${member.name} from the group?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.removeMember(member.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showLeaveOrDeleteDialog(BuildContext context, GroupChatProvider provider) {
    if (provider.groupDetails == null) return;

    final bool isLastAdminButNotLastMember =
        provider.groupDetails!.adminIds.length == 1 &&
            provider.groupDetails!.adminIds.first == provider.currentUserId &&
            provider.groupDetails!.memberIds.length > 1;

    final bool isLastMember = provider.groupDetails!.memberIds.length == 1;

    // Titel und Inhalt basierend auf dem Fall bestimmen
    String title = "Leave Group";
    String content = "Are you sure you want to leave this group?";
    if (isLastAdminButNotLastMember) {
      title = "Assign New Admin";
      content = "You are the last admin. Please assign a new admin before leaving.";
    } else if (isLastMember) {
      title = "Delete Group";
      content = "You are the last member. Leaving will delete the group for everyone. Are you sure?";
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),

          if (isLastAdminButNotLastMember)
          // Button, um Admin zuzuweisen
            TextButton(
              child: const Text("Assign Admin"),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature 'Assign Admin' not implemented.")));
              },
            )
          else
          // Button zum Verlassen oder Löschen
            TextButton(
              child: Text(isLastMember ? "Delete" : "Leave", style: const TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(ctx).pop(); // Dialog schließen

                await provider.leaveOrDeleteGroup();

                if (!context.mounted) return;

                if (provider.error == null) {
                  // Bei Erfolg immer zur Hauptseite zurück
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${provider.error}"), backgroundColor: Colors.red),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _navigateAndAddMembers(BuildContext context, GroupChatProvider provider) async {
    final List<ChatUserEntity>? result = await Navigator.of(context).push<List<ChatUserEntity>>(
      MaterialPageRoute(
        builder: (_) => UserSearchScreen(
          multiSelectionEnabled: true,
          initialSelectedUserIds: [], // Start mit leerer Auswahl für neue Mitglieder
          excludeUserIds: provider.groupDetails!.memberIds, // Wichtig!
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final idsToAdd = result.map((e) => e.id).toList();
      await provider.addMembers(idsToAdd);
    }
  }
}