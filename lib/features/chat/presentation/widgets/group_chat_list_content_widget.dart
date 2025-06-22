import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provider
import '../providers/group_chat_list_provider.dart';

// Widgets
import 'group_chat_list_item_widget.dart';

// Screens (für Navigation)
import '../screens/group_chat_screen.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class GroupChatListContentWidget extends StatelessWidget {
  const GroupChatListContentWidget({super.key});

  void _navigateToGroupChat(BuildContext context, String groupId, String groupName) {
    AppLogger.info("GroupChatListContentWidget: Navigating to group chat $groupId ($groupName)");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupChatScreen( // Der Screen, den wir als nächstes erstellen/refactorn
          groupId: groupId,
          initialGroupName: groupName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.watch hier, da sich das Widget bei Änderungen im Provider neu bauen soll
    final provider = context.watch<GroupChatListProvider>();
    AppLogger.debug("GroupChatListContentWidget: Building. Group count: ${provider.groupChats.length}, isLoading: ${provider.isLoading}");

    if (provider.isLoading && provider.groupChats.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Fehler: ${provider.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  AppLogger.info("GroupChatListContentWidget: 'Erneut versuchen' tapped.");
                  provider.forceReloadGroupChats();
                },
                child: const Text("Erneut versuchen"),
              )
            ],
          ),
        ),
      );
    }

    if (provider.groupChats.isEmpty) {
      return const Center(
        child: Text(
          'Keine Gruppenchats vorhanden.\nErstelle eine neue Gruppe oder trete einer bei!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // Sortieren der Gruppen nach der letzten Nachricht, falls gewünscht und nicht schon im Stream sortiert
    // List<GroupChatEntity> sortedGroups = List.from(provider.groupChats);
    // sortedGroups.sort((a, b) {
    //   if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
    //   if (a.lastMessageTime == null) return 1; // nulls ans Ende
    //   if (b.lastMessageTime == null) return -1;
    //   return b.lastMessageTime!.compareTo(a.lastMessageTime!); // Neueste zuerst
    // });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // Padding für die Liste
      itemCount: provider.groupChats.length, // Verwende die potenziell sortierte Liste
      itemBuilder: (context, index) {
        final group = provider.groupChats[index]; // Verwende die potenziell sortierte Liste
        return GroupChatListItemWidget(
          group: group,
          onTap: () => _navigateToGroupChat(context, group.id, group.name),
        );
      },
    );
  }
}