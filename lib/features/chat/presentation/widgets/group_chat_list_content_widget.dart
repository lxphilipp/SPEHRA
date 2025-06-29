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
        builder: (_) => GroupChatScreen(
          groupId: groupId,
          initialGroupName: groupName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme am Anfang holen
    final provider = context.watch<GroupChatListProvider>();
    AppLogger.debug("GroupChatListContentWidget: Building. Group count: ${provider.groupChats.length}, isLoading: ${provider.isLoading}");

    if (provider.isLoading && provider.groupChats.isEmpty) {
      // OPTIMIERT: Der Indikator erbt seine Farbe jetzt automatisch vom Theme.
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fehler: ${provider.error}',
                textAlign: TextAlign.center,
                // OPTIMIERT: Verwendet Text- und Farbstil aus dem Theme
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
              ),
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
      return Center(
        child: Text(
          'Keine Gruppenchats vorhanden.\nErstelle eine neue Gruppe oder trete einer bei!',
          textAlign: TextAlign.center,
          // OPTIMIERT: Verwendet Text- und Farbstil aus dem Theme
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      itemCount: provider.groupChats.length,
      itemBuilder: (context, index) {
        final group = provider.groupChats[index];
        return GroupChatListItemWidget(
          group: group,
          onTap: () => _navigateToGroupChat(context, group.id, group.name),
        );
      },
    );
  }
}