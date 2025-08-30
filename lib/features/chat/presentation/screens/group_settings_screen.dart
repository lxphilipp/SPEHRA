import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider & Entities
import '../../../challenges/presentation/screens/challenge_list_screen.dart';
import '../providers/group_chat_provider.dart';
import '../../domain/entities/chat_user_entity.dart';
import 'user_search_screen.dart'; // Für die Mitgliedersuche

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
      appBar: AppBar(
        title: const Text("Group Info"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: (group.imageUrl != null && group.imageUrl!.isNotEmpty)
                          ? NetworkImage(group.imageUrl!)
                          : null,
                      child: group.imageUrl == null
                          ? Icon(Iconsax.people, size: 40, color: theme.colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (amIAdmin)
                          IconButton(
                            icon: Icon(Iconsax.edit, color: theme.colorScheme.onSurfaceVariant, size: 20),
                            onPressed: () => _showEditNameDialog(context, provider, group.name),
                          ),
                      ],
                    ),
                    Text(
                      "${group.memberIds.length} members",
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // --- Mitgliederliste ---
              Text(
                "Members",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (amIAdmin)
                ListTile(
                  leading: Icon(Iconsax.user_add, color: theme.colorScheme.primary),
                  title: Text("Add Members", style: TextStyle(color: theme.colorScheme.primary)),
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
                  final isMemberAdmin = group.adminIds.contains(memberId);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (memberDetails?.imageUrl != null && memberDetails!.imageUrl!.isNotEmpty)
                            ? NetworkImage(memberDetails.imageUrl!)
                            : null,
                        child: (memberDetails?.imageUrl == null || memberDetails!.imageUrl!.isEmpty)
                            ? Text(memberDetails!.name.isNotEmpty ? memberDetails.name.substring(0, 1).toUpperCase() : "?")
                            : null,
                      ),
                      title: Text(memberDetails.name),
                      trailing: isMemberAdmin ? Text("Admin", style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12)) : null,
                      onLongPress: (amIAdmin && memberId != provider.currentUserId)
                          ? () => _showRemoveMemberDialog(context, provider, memberDetails)
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Divider(),

              if (amIAdmin)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Iconsax.cup, color: theme.colorScheme.primary),
                  title: Text(
                    "Start new group challenge",
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  onTap: () => _startChallengeSelection(context),
                ),

              // --- Aktionen ---
              ListTile(
                leading: Icon(Iconsax.logout, color: theme.colorScheme.error),
                title: Text("Leave Group", style: TextStyle(color: theme.colorScheme.error)),
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
          FilledButton(
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text("Are you sure you want to remove ${member.name} from the group?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text("Remove"),
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
    final theme = Theme.of(context);

    final bool isLastAdminButNotLastMember =
        provider.groupDetails!.adminIds.length == 1 &&
            provider.groupDetails!.adminIds.first == provider.currentUserId &&
            provider.groupDetails!.memberIds.length > 1;
    final bool isLastMember = provider.groupDetails!.memberIds.length == 1;
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
            FilledButton(
              child: const Text("Assign Admin"),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature 'Assign Admin' not implemented.")));
              },
            )
          else
            TextButton(
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: Text(isLastMember ? "Delete" : "Leave"),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await provider.leaveOrDeleteGroup();
                if (!context.mounted) return;
                if (provider.error == null) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: ${provider.error}"),
                      backgroundColor: theme.colorScheme.error,
                    ),
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
          initialSelectedUserIds: [],
          excludeUserIds: provider.groupDetails!.memberIds,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final idsToAdd = result.map((e) => e.id).toList();
      await provider.addMembers(idsToAdd);
    }
  }
  void _startChallengeSelection(BuildContext context) async {
    // Wir holen den Provider hier, ohne auf Änderungen zu lauschen,
    // da wir nur eine Aktion ausführen wollen.
    final provider = context.read<GroupChatProvider>();

    // 1. Navigiere zum ChallengeListScreen und warte auf ein Ergebnis.
    //    Wir müssen den ChallengeListScreen eventuell anpassen, damit er eine Challenge zurückgeben kann.
    final selectedChallengeId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        // Wir übergeben eine Flag, um dem Screen mitzuteilen, dass er im "Auswahlmodus" ist.
        builder: (_) => const ChallengeListScreen(isSelectionMode: true),
      ),
    );

    if (selectedChallengeId != null && context.mounted) {
      await provider.startGroupChallenge(selectedChallengeId);

      // 4. (Optional) Gib dem Admin Feedback und schließe den Einstellungs-Screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sent invite to group!')),
      );
      Navigator.of(context).pop();
    }
  }
}