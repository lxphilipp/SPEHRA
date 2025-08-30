// lib/features/chat/presentation/widgets/group_chat_list_content_widget.dart

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

  void _navigateToGroupChat(
      BuildContext context, String groupId, String groupName) {
    AppLogger.info(
        "GroupChatListContentWidget: Navigating to group chat $groupId ($groupName)");
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
    final theme = Theme.of(context);
    final provider = context.watch<GroupChatListProvider>();
    AppLogger.debug(
        "GroupChatListContentWidget: Building. Group count: ${provider.sortedGroupChats.length}, isLoading: ${provider.isLoading}");

    if (provider.isLoading && provider.sortedGroupChats.isEmpty) {
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
                'Error: ${provider.error}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  AppLogger.info(
                      "GroupChatListContentWidget: 'Try again' tapped.");
                  provider.forceReloadGroupChats();
                },
                child: const Text("Try again"),
              )
            ],
          ),
        ),
      );
    }

    if (provider.sortedGroupChats.isEmpty) {
      return Center(
        child: Text(
          'No group chats started yet.\n Join or create a new group chat!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final groupChats = provider.sortedGroupChats;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      itemCount: groupChats.length,
      itemBuilder: (context, index) {
        final group = groupChats[index];
        return GroupChatListItemWidget(
          group: group,
          onTap: () => _navigateToGroupChat(context, group.id, group.name),
        );
      },
    );
  }
}